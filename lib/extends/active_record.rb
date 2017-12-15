require 'rubygems'
require 'active_record'

module ComputeTypeWithPageFallback

  #
  # This is an intervention into how activerecord deals with STI (single table
  # inheritance). Normally, activerecord throws a SubclassNotFound exception
  # if it is not able to find a class name that matches the type.
  #
  # This makes a lot of sense normally. However, because crabgrass lets you add
  # and remove page types easily, we want to make it so that unknown page types
  # don't cause rails to bomb out. Rather, it should just instantiate a generic
  # page.
  #
  # The method 'compute_type(type_name)' is a protected class method called by
  # ActiveRecord#instantiate(record) in order to create a ActiveRecord object
  # from a database record using STI if needed. compute_type() should raise
  # NameError if the type can't be found.
  #
  # The variable type_name comes from the 'type' column of the record.
  #
  # rails notes:
  # Returns the class type of the record using the current module as a prefix. So descendants of
  # MyApp::Business::Account would appear as MyApp::Business::AccountSubclass.
  #

  protected

  def compute_type(type_name)
    super(type_name)
  rescue NameError => e
    if type_name =~ /Page$/
      ActiveSupport::Dependencies.constantize('DiscussionPage')
    else
      raise e
    end

    # Some of our models break the usual path <-> name relationship (such as "RequestNotice" within
    # app/models/notice/request_notice.rb). So in cases where "Notice" is asked to compute the type
    # "RequestNotice", it finds the correct file (because it first tries Notice::RequestNotice), but
    # then fails when that file doesn't define the expected "Notice::RequestNotice".
    # We solve such situations by falling back to asking ActiveRecord::Base to compute the type,
    # which will fall back to the bare 'type_name', because there is no file "active_record/base/request_notice.rb".
  rescue LoadError => e
    raise e if self == ActiveRecord::Base
    ActiveRecord::Base.compute_type(type_name)
  end

end

ActiveRecord::Base.singleton_class.prepend ComputeTypeWithPageFallback

ActiveRecord::Base.class_eval do
  #
  # Crabgrass uses exceptions in most places to display error messages.
  # This method adds an easy way to generate RecordInvalid exceptions
  # without attempting to save the record (e.g. save!)
  #
  def validate!
    raise ActiveRecord::RecordInvalid.new(self) unless valid?
  end

  # used to automatically apply greencloth to a field and store it in another field.
  # for example:
  #
  #    format_attribute :description
  #
  # Will save an html copy in description_html. This other column must exist.
  # The other column will return html_safe values.
  #
  #    format_attribute :summary, :options => [:lite_mode]
  #
  # Will pass :lite_mode as an option to GreenCloth.
  #
  def self.format_attribute(attr_name, flags = {})
    flags[:options] ||= []
    # class << self; include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, WhiteListHelper; end
    define_method("#{attr_name}_html") do
      super().try.html_safe
    end
    before_save :"format_#{attr_name}"
    define_method("format_#{attr_name}") do
      return unless formatted_attribute_needs_update?(attr_name)
      plain = send(attr_name.to_s).strip
      context = respond_to?('owner_name') ? owner_name : 'page'
      value = GreenCloth.new(plain, context, flags[:options]).to_html
      send("#{attr_name}_html=", value)
    end
  end

  def formatted_attribute_needs_update?(attr_name)
    return false if send(attr_name.to_s).blank?
    return true if send("#{attr_name}_html").blank?
    send("#{attr_name}_changed?") && !send("#{attr_name}_html_changed?")
  end

  # used to give a default value to serializable attributes
  def self.serialize_default(attr_name, default_object)
    attr_name = attr_name.to_sym

    send :define_method, attr_name do
      read_attribute(attr_name) || write_attribute(attr_name, default_object.clone)
    end
  end

  # make sanitize_sql public so we can use it ourselves
  def self.quote_sql(condition)
    sanitize_sql_array(condition)
  end

  def quote_sql(condition)
    self.class.quote_sql(condition)
  end

  # used by STI models to name fields appropriately
  # alias_attr :user, :object
  def self.alias_attr(new, old)
    if method_defined? old
      alias_method new, old
      alias_method "#{new}=", "#{old}="
      define_method("#{new}_id")   { read_attribute("#{old}_id") }
      define_method("#{new}_name") { read_attribute("#{old}_name") }
      define_method("#{new}_type") { read_attribute("#{old}_type") }
    else
      define_method(new) { read_attribute(old) }
      define_method("#{new}=") { |value| write_attribute(old, value) }
    end
  end

  # see http://blog.evanweaver.com/articles/2006/12/26/hacking-activerecords-automatic-timestamps/
  # only works because rails is not thread safe.
  # but a thread safe version could be written.
  def without_timestamps
    self.class.record_timestamps = false
    yield
    self.class.record_timestamps = true
  end

end

#
# What is going on here!?
# Crabgrass requires MyISAM for the page_terms and the ability to add fulltext
# indexes. Additionally, since we are tied to mysql, we might as well be able
# to use it properly and specify the index length.
#
# These are not possible in the normal schema.rb file, so this little hack
# will insert the correct raw MySQL specific SQL commands into schema.rb
# in the following cases:
#
#  * if the index name matches /fulltext/, then the index is created as a
#    fulltext index and table is converted to be MyISAM.
#  * if the index name ends with a number, we assume this is the length of
#    the index. if the index is composite, then we assume there are multiple
#    length suffixes.
#    eg: idx_name_and_language_5_2 => CREATE INDEX ... (name(5),country(2))
#
module ActiveRecord
  class SchemaDumper #:nodoc:
    # modifies index support for MySQL full text indexes
    def indexes(table, stream)
      indexes = @connection.indexes(table)
      indexes.each do |index|
        if index.name =~ /fulltext/ and @connection.is_a?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
          stream.puts %(  execute "ALTER TABLE #{index.table} ENGINE = MyISAM")
          stream.puts %(  execute "CREATE FULLTEXT INDEX #{index.name} ON #{index.table} (#{index.columns.join(',')})")
        elsif index.name =~ /\d+$/ and @connection.is_a?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
          lengths = index.name.match(/(_\d+)+$/).to_s.split('_').select(&:present?)
          index_parts = []
          index.columns.size.times do |i|
            if lengths[i] == '0'
              index_parts << index.columns[i]
            else
              index_parts << index.columns[i] + '(' + lengths[i] + ')'
            end
          end
          stream.puts %(  execute "CREATE INDEX #{index.name} ON #{index.table} (#{index_parts.join(',')})")
        else
          stream.print "  add_index #{index.table.inspect}, #{index.columns.inspect}, :name => #{index.name.inspect}"
          stream.print ', :unique => true' if index.unique
          stream.puts
        end
      end
      stream.puts unless indexes.empty?
    end
  end
end

module ActiveRecord::AttributeMethods::ClassMethods
  def create_time_zone_conversion_attribute?(name, column)
    # FIXME: this is a hack!
    skip_time_zone_conversion_for_attributes ||= []
    time_zone_aware_attributes && !skip_time_zone_conversion_for_attributes.include?(name.to_sym) && %i[datetime timestamp].include?(column.type)
  end
end
