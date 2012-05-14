#
# A singleton class to manage holders
#

module CastleGates
class Holder

  ##
  ## VARIABLES
  ##

  #
  # class attributes
  #
  class << self
    attr_reader :holder_defs
  end
  @holder_defs = {}

  ##
  ## CLASS METHODS
  ##

  def self.define(&block)
    self.instance_eval(&block)
  end

  #
  # defines a new holder
  #
  def self.add_holder(prefix, name, options=nil)
    abstract = false
    type = nil

    if options.nil?
      abstract = true
    elsif options[:model]
      model = options[:model]
      raise ArgumentError.new unless model.is_a?(Class) && model.ancestors.include?(ActiveRecord::Base)
      model.send(:extend, CastleGates::ActsAsHolder::ClassMethods)
      model.send(:include, CastleGates::ActsAsHolder::InstanceMethods)
      type = model
    elsif options[:association]
      association = options[:association]
      raise ArgumentError.new unless association.is_a?(ActiveRecord::Reflection::MacroReflection)
      association.class_eval do
        def holder_code_suffix
          proxy_owner.id
        end
        attr_accessor :holder_definition
      end
      type = association
    else
      raise ArgumentError.new(options)
    end

    holder_def = HolderDefinition.new(name, {:type => type, :prefix => prefix, :abstract => abstract})
    if type.respond_to? :holder_definition
      type.holder_definition = holder_def
    end
    holder_defs[name] = holder_def
    holder_def
  end

  #
  # returns a holder code for any object
  #
  def self.code(object)
    holder_def = get_definition(object)
    raise ArgumentError.new('no such holder (%s)' % object.inspect) unless holder_def

    code_prefix = holder_def.prefix
    if holder_def.abstract
      object_id = ""
    else
      object_id = object.holder_code_suffix
    end
    "#{code_prefix}#{object_id}"
  end

  #
  # returns a holder code for an array of ids
  #
  def self.codes(holder, ids)
    holder_def = get_definition(holder)
    code_prefix = holder_def.prefix
    ids.collect do |id|
      "#{code_prefix}#{id}"
    end
  end

  #
  # converts whatever is passed in to an appropriate holder definition
  #
  def self.get_definition(obj)
    if obj.is_a? Symbol
      holder_defs[obj]
    elsif obj.respond_to? :holder_definition
      obj.holder_definition
    else
      raise ArgumentError.new("not a key holder: %s" % obj.inspect)
    end
  end

  def self.all_codes_for_holder(holder)
    codes = []
    if holder.respond_to?(:holders) && holder_list = holder.holders
      codes = holder_list.collect {|holder| Holder.code(holder)}
    elsif holder.respond_to?(:holder_codes) && return_value = holder.holder_codes
      if return_value.is_a? Hash
        codes = codes_from_hash(return_value)
      elsif return_value.is_a? Array
        codes = codes_from_array(return_value)
      end
    end
    codes << Holder.code(holder)
  end

  private

  #
  # returns holder codes for {:holder => x, :ids => [1,2,3]}
  #
  def self.codes_from_hash(hsh)
    Holder.codes(hsh[:holder], hsh[:ids])
  end

  #
  # returns holder codes for an array
  #
  def self.codes_for_array(arry)
    codes = []
    arry.each do |code|
      if code.is_a? Hash
        codes += codes_from_hash(id)
      else
        codes << code
      end
    end
    codes
  end

end
end
