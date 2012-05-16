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
      key.add_gates! gates
      if self.respond_to? :after_grant_access
        as_array(gates).each do |gate|
          after_grant_access(holder, gate)
        end
      end
    end
    reset_key_cache
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
      key.remove_gates! gates
      if self.respond_to? :after_revoke_access
        as_array(gates).each do |gate|
          after_revoke_access(holder, gate)
        end
      end
    end
    reset_key_cache
  end

  # this appears to be only used for testing.
  #def keys_by_lock
  #  keys.inject({}) do |hash, key|
  #    key.locks.each do |lock|
  #      hash[lock] ||= []
  #      hash[lock].push key
  #    end
  #    hash
  #  end
  #end

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
    @key_cache ||= {}
    @key_cache[holder.code] ||= keys.for_holder(holder)
  end

  #
  # just like keys.reset, but works with our manual caching.
  #
  def reset_key_cache
    @key_cache = {}
    @gate_bitfield_cache = {}
  end

  #
  # returns the aggregated gate_bitfield for a set of keys.
  # the result is cached on the holder.
  #
  def gate_bitfield_for_keys(keys, holder)
    @gate_bitfield_cache ||= {}
    @gate_bitfield_cache[holder.code] ||= begin
      bitfield = Key::gate_bitfield(keys)
      if bitfield.nil?
        # no actual keys, so lets fall back to the defaults
        gate_set.default_bits(holder)
      else
        bitfield
      end
    end
  end

end
end
end