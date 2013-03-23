#
# Castle instance methods
#

module CastleGates
module Castle
module InstanceMethods

  #
  # returns true if the gate is openable by the holder.
  #
  # for example:
  #
  #   castle.access?(current_user => :door)
  #
  def access?(args)
    holder, gate_symbol = args.first
    holder = Holder[holder]

    keys     = keys_for_holder(holder)
    bitfield = gate_bitfield_for_keys(keys, holder)
    gate     = gate_set.get(gate_symbol)

    unless gate
      raise ArgumentError.new "Gate '#{gate_symbol}' unknown"
    end

    gate.opened_by? bitfield
  end

  #
  # alternate signature
  #
  def has_access!(gate_symbol, holder)
    access?(holder => gate_symbol) || raise(CastleGates.exception_class.new)
  end
  def has_access?(gate_symbol, holder)
    access?(holder => gate_symbol)
  end

  #
  # grant access to a gate
  #
  # adds the right bits to specified holder(s) keys so that they can open the specified gate(s)
  #
  # if the keys don't exist, they are created.
  #
  def grant_access!(args)
    holders, gates = args.first

    unless holders and gates
      raise ArgumentError.new('argument must be in the form {holder => gate}')
    end
    unless gate_set.gates_exist?(gates)
      raise ArgumentError.new('one of these is not a gate %s' % gates.inspect)
    end

    as_array(holders).each do |holder|
      holder = Holder[holder]
      key = keys.find_by_holder(holder)
      if key.add_gates!(gates) && self.respond_to?(:after_grant_access)
        after_grant_access(holder, as_array(gates))
      end
    end
    clear_key_cache
  end

  #
  # remove access to a gate
  #
  # zeros out the right bits on the specified holder(s) keys so that they cannot open the specified gate(s)
  #
  # if the keys don't exist, they are created.
  #
  def revoke_access!(args)
    holders, gates = args.first

    unless holders and gates
      raise ArgumentError.new('argument must be in the form {holder => gate}')
    end
    unless gate_set.gates_exist?(gates)
      raise ArgumentError.new('one of these is not a gate %s' % gates.inspect)
    end

    as_array(holders).each do |holder|
      holder = Holder[holder]
      key = keys.find_by_holder(holder)
      if key.remove_gates!(gates) && self.respond_to?(:after_revoke_access)
        after_revoke_access(holder, as_array(gates))
      end
    end
    clear_key_cache
  end

  #
  # just like keys.reset, but works with our manual caching.
  #
  def clear_key_cache
    self.class.key_cache[self.id] = {}
    self.class.gate_bitfield_cache[self.id] = {}
  end

  #
  # GATES
  #

  def gate_set
    self.class.gate_set
  end

  def gate(name)
    gate_set.get(name)
  end

  def gates
    self.class.gates
  end

  #
  # HOLDERS
  #

  def holders
    codes = keys.select_holder_codes
    Holder.codes_to_holders(codes)
  end

  protected

  #
  # to be overridden optionally by castles
  #
  def default_open_gates(holder)
  end

  private

  ##
  ## UTILITIES
  ##

  def as_array(obj)
    obj.is_a?(Array) ? obj : [obj]
  end

  ##
  ## CACHE
  ##

  #
  # this does not really return the keys. it returns a named scope
  # to find the keys that correspond to this castle and the holder
  # (and all the associated holders)
  #
  # the result is cached.
  #
  def keys_for_holder(holder)
    self.class.key_cache[self.id] ||= {}
    self.class.key_cache[self.id][holder.code] ||= keys.for_holder(holder)
  end

  #
  # returns the aggregated gate_bitfield for a set of keys.
  # the result is cached on the holder.
  #
  def gate_bitfield_for_keys(keys, holder)
    self.class.gate_bitfield_cache[self.id] ||= {}
    self.class.gate_bitfield_cache[self.id][holder.code] ||= begin
      bitfield = Key::gate_bitfield(keys)
      if bitfield.nil?
        # no actual keys, so lets fall back to the defaults
        bitfield = gate_set.default_bits(self, holder)
        if associated_holder = holder.association_with(self)
          bitfield |= gate_set.default_bits(self, associated_holder)
        else
          bitfield
        end
      else
        bitfield
      end
    end
  end

end
end
end
