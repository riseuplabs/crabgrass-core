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
      elsif @object.respond_to?(:holder_type)
        definition = self.class.holder_defs_by_class[@object.holder_type]
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
  # must implement the method 'holder_codes'
  #
  def all_codes
     codes = []
     if @object.respond_to?(:holder_codes) && return_value = @object.holder_codes
       if return_value.is_a? Hash
         codes = self.class.codes_from_hash(return_value)
       elsif return_value.is_a? Array
         codes = self.class.codes_from_array(return_value)
       end
     end
     codes << self.code
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
  def self.[](obj, context = nil)
    return obj if obj.is_a?(Holder)
    if obj.is_a?(Symbol) && holder_defs[obj].nil?
      obj = context.associated(obj)
    end
    Holder.new(obj)
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
      holder_defs_by_class[holder_identifier(holder)] = hdef
    end
    hdef
  end

  def self.holder_identifier(holder)
    if holder.respond_to?(:holder_type)
      id = holder.holder_type
    elsif holder.is_a?(Class)
      id = holder.name
    elsif !holder.is_a?(Symbol)
      id = holder.class.name
    end
  end

  def self.eval_block(block, options)
    if block
      if model = options[:model]
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
    options[:association_name] = association.relationship
    options[:model] ||= association.owner_class
    association
  end

end
end
