#
# Class Methods for Castles
#

module CastleGates
module Castle
module ClassMethods

  #
  # Used to find castles that with particular access. Assumes 'keys' table is joined in.
  #
  def conditions_for_gates(gate_names)
    gate_names = [gate_names] unless gate_names.is_a? Array
    bits = gate_set.bits(gate_names)
    "(#{bits} & ~keys.gate_bitfield) = 0"
  end

  ##
  ## GATES
  ##

  #
  # Adds a new gate to this castle
  #
  def gate(*args)
    gate_set.add( Gate.new(*args) )
  end

  def gate_set
    @gate_set ||= begin
      if superclass.respond_to?(:gate_set)
        superclass.gate_set
      else
        GateSet.new
      end
    end
  end

  def gates
    gate_set.values
  end

  ##
  ## CACHE
  ## This is implemented here, so that different instances with the same ID will share cache.
  ##

  def clear_key_cache
    @key_cache = {}
    @gate_bitfield_cache = {}
  end

  def key_cache
    @key_cache ||= {}
  end

  def gate_bitfield_cache
    @gate_bitfield_cache ||= {}
  end

end
end
end
