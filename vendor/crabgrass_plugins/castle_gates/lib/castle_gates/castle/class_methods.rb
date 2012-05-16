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
    unless bits
      raise ArgumentError.new 'bad gate names %s' % gate_names.inspect
    end
    "(#{bits} & ~keys.gate_bitfield) = 0"
  end

  ##
  ## GATES
  ##

  #
  # Adds a new gate to this castle
  #
  def add_gate(*args)
    gate_set.add( Gate.new(*args) )
  end

  def gate_set
    @gate_set ||= GateSet.new
  end

  def gates
    gate_set.values
  end

end
end
end