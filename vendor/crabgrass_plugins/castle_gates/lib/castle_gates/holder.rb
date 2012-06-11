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

  def to_s
    definition.name
  end

  #
  # returns the holder definition
  #
  def definition
    @definition ||= begin
      if @object.is_a? Symbol
        definition = self.class.holder_defs[@object]
      elsif @object.respond_to?(:holder_class)
        definition = self.class.holder_defs_by_class[@object.holder_class.name]
      else
        definition = self.class.holder_defs_by_class[@object.class.name]
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
  # TODO: this is not actually used anymore, so maybe it should be ripped out.
  #
  def association_with(castle)
    possible_holder = definition.associated.find do |hdef|
      hdef.model.name == definition.model.name && hdef.association_model_name == castle.class.base_class.name
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
    attr_reader :holder_defs_by_class

  end
  @holder_defs = {}
  @holder_defs_by_prefix = {}
  @holder_defs_by_class = {}

  #
  # defines a new holder
  #
  def self.add_holder(prefix, name, options=nil, &block)
    options ||= {}
    options[:abstract] = true if !(options[:model] || options[:association])
    options[:prefix] = prefix
    holder = nil

    if options[:model]
      holder = holder_from_model(options)
    elsif options[:association]
      holder = holder_from_association(options)
    elsif options[:abstract]
      holder = name
    else
      raise ArgumentError.new(options.inspect)
    end

    eval_block(block, options)

    create_holder_definition(holder, name, options)
  end

  #
  # allows multiple classes to share the same holder_definition
  #
  def self.add_holder_alias(name, model_class)
    hdef = holder_defs[name]
    raise ArgumentError.new('bad model') unless model_class.is_a?(Class)
    holder_defs_by_class[model_class.name] = hdef
    model_class.send(:include, CastleGates::ActsAsHolder::InstanceMethods)
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
      find_by_code(code) if code
    end
  end

  def self.find_by_code(code)
    prefix = code.to_s[0..0]
    id = code.to_s[1..-1]
    holder_def = holder_defs_by_prefix[prefix]
    if holder_def
      Holder[holder_def.get_holder_from_id(id)]
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

  ##
  ## HOLDER DEFINITION HELPERS
  ##

  def self.create_holder_definition(holder, name, options)
    holder_defs[name] ||= HolderDefinition.new(name, options)
    hdef = holder_defs[name]
    holder_defs_by_prefix[hdef.prefix] = hdef
    if !holder.nil?
      if holder.is_a?(Class)
        holder_defs_by_class[holder.name] = hdef
      elsif !holder.is_a?(Symbol)
        holder_defs_by_class[holder.class.name] = hdef
      end
    end
    hdef
  end

  def self.eval_block(block, options)
    if block
      if model = (options[:association_model] || options[:model])
        after_reload(model) do |model|
          model.class_eval &block
        end
      end
    end
  end

  def self.holder_from_model(options)
    model = options[:model]
    raise ArgumentError.new unless model.is_a?(Class) && model.ancestors.include?(ActiveRecord::Base)
    after_reload(model) do |model|
      model.send(:include, CastleGates::ActsAsHolder::InstanceMethods)
    end
    model
  end

  def self.holder_from_association(options)
    association = options[:association]
    raise ArgumentError.new unless association.is_a?(ActiveRecord::Reflection::MacroReflection)
    after_reload(association.class) do |klass|
      klass.class_eval do
        def holder_code_suffix
          proxy_owner.id
        end
      end
    end
    options[:association_name] = association.name
    options[:association_model] = association.active_record
    options[:model] = association.klass
    association
  end

end
end
