#
# Castle Class Methods
#

module CastleGates
module Castle
module ClassMethods

  #def locks
  #  self.locks_for_bits ~0
  #end

  #protected

  #def keys_open_locks?(keys, locks)
  #  openable_gates = keys.gate_bitfield
  #  gates_to_open = bits_for_locks(locks)
  #  (gates_to_open & ~openable_gates) == 0
  #end

  #private

  def conditions_for_locks(locks)
    bit = self.bits_for_locks(locks)
    "(#{bit} & ~keys.gate_bitfield) = 0"
  end

  #def bits_for_locks(locks)
  #  return ~0 if locks == :all
  #  return self.bit_for(locks) unless locks.respond_to? :inject
  #  locks.inject(0) {|any, lock| any | self.bit_for(lock)}
  #end


  #def locks_for_bits(bits)
  #  CastleGates::Locks.locks_for(self, bits)
  #end

  #def bit_for(lock)
  #  CastleGates::Locks.bit_for(self, lock)
  #end

  def key_allowed?(lock, holder)
    options = CastleGates::Locks.options_for(self, lock)
    return true unless without = options[:without]
    sym = holder.to_sym
    without.respond_to?(:include?) ?
      !without.include?(sym) :
      without != sym
  end

  #
  # Used to add locks to a class
  #
  # Arguments:
  # * either a list of lock symbols
  # * or an array and an options hash
  # * or a locks hash and an options hash
  #
  # The locks hash has lock symbols as keys and bit indexes as values
  #
  # Options:
  # * without: This lock does not apply for the given key
  #
  # Examples:
  #
  # User.add_locks :view, :pester
  # User.add_locks :see_contacts => 4
  # User.add_locks({:request_contact => 5}, :without => :friends)
  #
  #def add_locks(*args)
  #  if args.first.is_a? Enumerable
  #    locks = args.first
  #    options = args.second
  #  else
  #    locks = args
  #  end
  #  CastleGates::Locks.add_bits(self.name, locks)
  #  CastleGates::Locks.add_options(self.name, locks, options) if options
  #end

  ##
  ## GATES
  ##

  #
  # Adds a new gate to this castle
  #
  def add_gate(gate_definition)
    gate_set.add( Gate.new(gate_definition) )
  end

  #
  # class attribute accessor
  #
  def gate_set
    @gate_set ||= GateSet.new
  end
  alias :gates :gate_set

end
end
end