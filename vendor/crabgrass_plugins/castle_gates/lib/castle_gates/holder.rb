#
# A Holder is a thin proxy around some *thing* that might hold keys.
#
# The actual thing might be an ActiveRecord or ActiveRecord::Association, or
# it could be a symbol.
#

module CastleGates
class Holder

  attr_accessor :keys

  def initialize(object)
    @object = object
  end

  ##
  ## INSTANCE METHODS
  ##

  #
  # A Holder is a proxy for the real holder.
  #

  def method_missing(meth, *args, &block)
    @object.send(meth, *args, &block)
  end

  def respond_to?(meth)
    @object.respond_to?(meth)
  end

  def is_a?(clss)
    clss == Holder || @object.is_a?(clss)
  end

  def ==(other_object)
    @object == other_object
  end

  def id
    @object.id
  end

  #
  # returns the holder definition
  #
  def definition
    @definition ||= begin
      if @object.is_a? Symbol
        definition = self.class.holder_defs[@object]
      elsif @object.respond_to? :holder_definition
        definition = @object.holder_definition
      end
      raise ArgumentError.new("not a key holder: %s" % @object.inspect) unless definition
      definition
    end
  end

  ##
  ## KEYS
  ##

  def keys_to(castle)
    castle.keys.find_by_holder(self)
  end

  ##
  ## CODES
  ##

  #
  # returns a holder code prefix
  # this is the determined by the holder *type*
  #
  def code_prefix
    definition.prefix
  end

  #
  # returns the holder code suffix.
  # this is determined by the holder *object*
  # (for abstract holders with no objects, this returns empty string)
  #
  def code_suffix
    definition.abstract ? "" : @object.holder_code_suffix
  end

  #
  # returns a holder code for any object
  #
  def code
    "#{code_prefix}#{code_suffix}"
  end

  #
  # returns all the holder codes that this holder 'owns'
  #
  # In order to specify what holders a holder owns, the holder
  # must implement the method 'holders' or 'holder_codes'
  #
  def all_codes
     codes = []
     if @object.respond_to?(:holder_codes) && return_value = @object.holder_codes
       if return_value.is_a? Hash
         codes = self.class.codes_from_hash(return_value)
       elsif return_value.is_a? Array
         codes = self.class.codes_from_array(return_value)
       end
     elsif @object.respond_to?(:holders) && holder_list = @object.holders
       codes = holder_list.collect {|holder| Holder[holder].code}
     end
     codes << self.code
  end

  #
  # When testing to see if a particular holder has default access to a castle, we
  # sometimes want to check both the holder itself and any other holders
  # that the holder might be associated with. Got that? Here is an example:
  #
  # Suppose you have a group (castle) and a user (holder). There is also a
  # holder defined called 'members_of_group'. To see if a user has default
  # access to the group, we should check to see if the user has direct default
  # access and also if they have default access via the 'members_of_group'.
  #
  # To repeat: this is only for fallback defaults. If there are key records, all
  # this is ignored.
  #
  # This method returns the associated holder, if any exist.
  #
  # For this to work, the holder definition for the association must have
  # a method that returns true if the two objects really are in association.
  # The name of the method is the name of the holder. Here is an example:
  #
  # holder 4, :minion_of_user, :association => User.associated(:minions) do
  #   def minion_of_user?(minion)
  #     minion_ids.include? minion.id
  #   end
  # end
  #
  def association_with(castle)
    possible_holder = definition.associated.find do |hdef|
      hdef.model == definition.model && hdef.association_model == castle.class.base_class
    end
    if possible_holder
      method_name = "#{possible_holder.name}?"
      if castle.respond_to?(method_name)
        if castle.send(method_name, self)
          return possible_holder
        end
      end
    end
  end

  ##
  ## CLASS METHODS
  ##

  #
  # class attributes
  #
  class << self
    attr_reader :holder_defs
    attr_reader :holder_defs_by_prefix
  end
  @holder_defs = {}
  @holder_defs_by_prefix = {}

  #
  # defines a new holder
  #
  def self.add_holder(prefix, name, options=nil, &block)
    options ||= {:abstract => true}
    options[:prefix] = prefix
    holder = nil

    if options[:model]
      model = options[:model]
      raise ArgumentError.new unless model.is_a?(Class) && model.ancestors.include?(ActiveRecord::Base)
      model.send(:extend, CastleGates::ActsAsHolder::ClassMethods)
      model.send(:include, CastleGates::ActsAsHolder::InstanceMethods)
      holder = model
    elsif options[:association]
      association = options[:association]
      raise ArgumentError.new unless association.is_a?(ActiveRecord::Reflection::MacroReflection)
      association.class_eval do
        def holder_code_suffix
          proxy_owner.id
        end
        attr_accessor :holder_definition
      end
      options[:association_name] = association.name
      options[:association_model] = association.active_record
      options[:model] = association.klass
      holder = association
    elsif options[:abstract]
      # eg :public
    else
      raise ArgumentError.new(options)
    end

    holder_def = HolderDefinition.new(name, options)
    if holder.respond_to? :holder_definition
      holder.holder_definition = holder_def
    end
    holder_defs[holder_def.name] = holder_def
    holder_defs_by_prefix[holder_def.prefix] = holder_def

    # add custom methods to the model
    if block
      model = options[:association_model] || options[:model]
      if model
        model.class_eval &block
      end
    end
    return holder_def
  end

  #
  # allows multiple classes to share the same holder_definition
  #
  def self.add_holder_alias(name, model)
    hdef = holder_defs[name]
    raise ArgumentError.new('bad model') unless model.is_a?(Class) && model.ancestors.include?(ActiveRecord::Base)
    model.send(:extend, CastleGates::ActsAsHolder::ClassMethods)
    model.send(:include, CastleGates::ActsAsHolder::InstanceMethods)
    model.holder_definition = hdef
  end

  #
  # ensures that the real holder gets wrapped in an object of class Holder
  #
  def self.[](obj)
    if obj.is_a?(Holder)
      obj
    else
      Holder.new(obj)
    end
  end

  #
  # Takes a list of holder codes, converts to actual Holders.
  # Returned list will have nil for entry that can't be converted correctly.
  #
  def self.codes_to_holders(codes)
    codes.collect do |code|
      if code
        prefix = code.to_s[0..0]
        id = code.to_s[1..-1]
        holder_def = holder_defs_by_prefix[prefix]
        if holder_def
          Holder[holder_def.get_holder_from_id(id)]
        end
      end
    end
  end

  private

  #
  # returns holder codes for {:holder => x, :ids => [1,2,3]}
  #
  # Used to parse result of 'holder_codes' method in Holder#all_codes
  #
  def self.codes_from_hash(hsh)
    ids = hsh[:ids]
    holder = Holder[hsh[:holder]]
    ids.collect do |id|
      "#{holder.code_prefix}#{id}"
    end
  end

  #
  # Returns holder codes for an array that might consist of codes or hashes.
  #
  # Used to parse result of 'holder_codes' method in Holder#all_codes
  #
  def self.codes_from_array(arry)
    codes = []
    arry.each do |code|
      if code.is_a? Hash
        codes += codes_from_hash(code)
      elsif code.is_a? Symbol
        codes << Holder[code].code
      else
        codes << code
      end
    end
    codes
  end

end
end
