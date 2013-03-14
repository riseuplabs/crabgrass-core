#
# used to define search filters. see extensions/search_filters
#

class SearchFilter
  # path definition
  attr_accessor :path_definition      # the raw path segment definition (eg /created_by/:user_id/)
  attr_accessor :path_keyword         # the keyword for this filter (eg created_by)
  attr_accessor :path_order           # weight for ordering this path segment (eg 10)
  attr_accessor :path_argument_count  # number of arguments to follow path segment (eg 1)

  # database query
  attr_accessor :sphinx_block
  attr_accessor :mysql_block
  attr_accessor :postgres_block
  attr_accessor :query_block

  # ui element
  attr_accessor :singleton      # if true, this filter can only be applied once.
  attr_accessor :section        # a symbol that determines the clustering of the ui controls
  attr_writer   :label          # the text for the ui control
  attr_accessor :html_block     # dynamic code for when you click on the ui control
  attr_accessor :html_options   # options for rendering the html
  attr_accessor :description    # hints for the user on how this filter works
  attr_accessor :exclude        # if set to the keyword of another filter, then the other filter
                                # may not be active when this one is

  def initialize(path_definition, &block)
    self.path_definition     = path_definition
    self.path_keyword        = path_definition.split('/')[1] # '/created_by/:user_id/' --> 'created_by'
    self.path_argument_count = path_definition.count(':')
    self.singleton           = true
    self.exclude             = false
    self.instance_eval &block
  ensure
    SearchFilter.add_filter(self.path_keyword, self)
    SearchFilter.add_to_section(self.section, self)
  end

  ##
  ## CLASS METHODS
  ##

  public

  # return the filter triggered by keyword
  def self.[](keyword)
    if keyword.is_a?(PathFinder::ParsedPath)
      keyword = keyword.first
    end
    SearchFilter.filters[keyword]
  end

  # returns array of filters for a particular section
  def self.filters_for_section(section_name)
    SearchFilter.sections[section_name]
  end

  # map: keyword -> filter object.
  def self.filters(); @@filters ||= {}; end

  # map: section name -> filter object array.
  def self.sections(); @@sections ||= {}; end

  private


  def self.add_to_section(section_name, search_filter)
     (SearchFilter.sections[section_name] ||= []) << search_filter
  end

  def self.add_filter(keyword, filter)
    SearchFilter.filters[keyword] = filter
  end

  ##
  ## PUBLIC METHODS
  ##

  public

  def has_args?
    self.path_argument_count != 0
  end

  def has_query?
    sphinx_block or mysql_block or postgres_block or query_block
  end

  def singleton?
    singleton
  end

  def has_control_ui?
    self.section.present?
  end

  def options
    self.html_options
  end

  # return the path of this filter, with these particular args.
  def path(args=nil)
    if args
      [@path_keyword, *args].join('/')
    else
      @path_keyword
    end
  end

  #
  # return a unique name that can be given to ui elements for this filter
  # bound to these particular args.
  #
  def name(args=nil)
    path(args).gsub(/[^0-9a-zA-Z]/,'')
  end

  ##
  ## FILTER DEFINITION METHODS
  ##

  protected

  # for sphinx specific query code
  def sphinx(&block)
    self.sphinx_block = block
  end

  # for mysql specific query code
  def mysql(&block)
    self.mysql_block = block
  end

  # for postgres specific query code
  def postgres(&block)
    self.postgres_block = block
  end

  # for generic query code
  def query(&block)
    self.query_block = block
  end

  def html(options={},&block)
    self.html_options = {:submit_button => true}.merge(options)
    self.html_block = block
  end

  ##
  ## utility methods used by instances
  ##

  protected

  def user_id(id)
    if id =~ /^\d*$/
      id
    else
      user = User.find_by_login(id)
      raise ErrorNotFound.new("#{:user.t} #{id.inspect}") unless user
      user.id
    end
  end

  def user_login(id)
    if id =~ /^\d*$/
      user = User.find_by_id(id)
      raise ErrorNotFound.new("#{:user.t} #{id.inspect}") unless user
      user.login
    else
      id.nameize # don't let invalid names through.
                 # The user might have given us dangerious input.
    end
  end

  def group_id(id)
    if id =~ /^\d*$/
      id
    else
      group = Group.find_by_name(id)
      raise ErrorNotFound.new("#{:group.t} #{id.inspect}") unless group
      group.id
    end
  end

  def group_name(id)
    if id =~ /^\d*$/
      group = Group.find_by_id(id)
      raise ErrorNotFound.new("#{:group.t} #{id.inspect}") unless group
      group.name
    else
      id.nameize # don't let invalid names through.
    end
  end

  ##
  ## UI DEFINITION
  ##

  public

  #
  # used to either define the label block, or to call the label block, or
  # return the static label.
  # The label block is used when a filter wants dynamic control over what the
  # label is. The args are the actual current args for the filter, if it is
  # active. Otherwise, the args will be empty.
  #
  def label(args=[], options={}, &block)
    if block
      set_label(&block)
    else
      # Send a dup of args, so path_args_to_hash won't remove values from args.
      get_label(args ? args.dup : [], options)
    end
  end

  def has_label?
    @label_block.present? or @label.present?
  end

  # returns the label for this filter, given a particular path.
  # some filters may change what the label says depending on the currently
  # active path (they do this by defining @label_block)
#  def label_from_path(path)
#    unless @label or @label_block
#      return nil
#    end
#    args = path.args_for(@path_keyword)
#    if args.size < @path_argument_count
#      args = [nil] * @path_argument_count
#    end
#    lbl = @label || @label_block.call(*args)
#    return lbl.t
#  end

  #
  # resolves the path definition of this filter based on the content of the
  # current path.
  #
  # ie:
  #   returns /created-by/green/ for a filter with definition /created-by/:user_id/
  #   if the current path contains /created-by/green/
  #
  #def path_segment(path)
  #  args = path.args_for(@path_keyword).reverse
  #  return @path_definition.gsub(/\/:\w+/) {|segment| "/#{args.pop}/"}
  #end

  private

  def get_label(args, options)
    if @label_block
      if has_args?
        options = options.merge(path_args_to_hash(args))
      end
      @label_block.call(options)
    elsif @label
      @label.t
    end
  end

  def set_label(&block)
    @label_block = block
  end

  #
  # takes an array of path arguments and converts this to a hash.
  #
  # for example:
  #
  #  given this:
  #    path_definition - '/most-stars-in/:time/:unit/'
  #    args - ['1','week']
  #
  #  returns:
  #    {:time => '1', :unit => 'week'}
  #
  def path_args_to_hash(args)
    hsh = {}
    if args.any?
      @path_definition.split('/').each do |segment|
        if segment.starts_with?(':')
          hsh[segment[1..-1].to_sym] = args.shift  # pop off the front
        end
      end
    end
    return hsh
  end

end

