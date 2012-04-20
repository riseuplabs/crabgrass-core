module CastleGates
class Holder

  ##
  ## VARIABLES
  ##

  #
  # class attributes
  #
  class << self
    attr_reader :holders_by_name
    attr_reader :holders_by_class
  end
  @holders_by_name = {}
  @holders_by_class = {}

  #
  # member attributes
  #
  attr_reader :name
  attr_reader :id
  attr_reader :type

  ##
  ## CLASS METHODS
  ##

  #
  # defines a new holder
  #
  def self.define(name, options)
    holder = Holder.new(name, options)
    holders_by_class[holder.type] = holder
    holders_by_name[holder.name] = holder
    holder
  end

  #
  # returns a holder code for any object
  #
  def self.code(object, type=nil)
    type ||= object.class
    holder_prefix = holders_by_class[type].id
    object_id = object.id
    "#{holder_prefix}#{object_id}"
  end

  #
  # returns a list holder objects from a list of symbols
  # the symbols array could already contain holder objects,
  # in which case we do nothing.
  #
  def self.list(objs)
    if objs.is_a? Enumerable
      objs.collect do |symbol_or_holder|
        get(symbol_or_holder)
      end
    else
      [get(objs)]
    end
  end

  #
  # converts whatever is passed in to an appropriate holder
  #
  def self.get(obj)
    if obj.is_a? Symbol
      holders_by_name[obj]
    else
      obj.holder
    end
  end

  ##
  ## INSTANCE METHODS
  ##

  #
  # return the code for this holder
  #
  def code
    self.class.code(self, self.type)
  end
  #alias :holder_code  :code
  alias :to_s  :code

  def holder
    self
  end

  def key_holders
    nil
  end

  def initialize(name, options)
    @name = name
    @id   = options[:id]
    @type = options[:type]
  end

end
end
