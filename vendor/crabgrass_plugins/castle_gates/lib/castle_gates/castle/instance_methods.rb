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
    holder = Holder[holder, self]

    gate     = gate_set.get(gate_symbol)
    unless gate
      raise ArgumentError.new "Gate '#{gate_symbol}' unknown"
    end

    gate.opened_by? bitfield_for_holder(holder)
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
  # grant access to gates
  #
  # adds the right bits to specified holder(s) keys so that they can open the specified gate(s)
  #
  # if the keys don't exist, they are created.
  #
  def grant_access!(access_hash)
    process_access_hash(access_hash) do |holder, gates|
      key = keys.find_by_holder(holder)
      if key.add_gates!(gates) && self.respond_to?(:after_grant_access)
        after_grant_access(holder, gates)
      end
    end
    clear_key_cache
  end

  #
  # remove access to gates
  #
  # zeros out the right bits on the specified holder(s) keys so that they cannot open the specified gate(s)
  #
  # if the keys don't exist, they are created.
  #
  def revoke_access!(access_hash)
    process_access_hash(access_hash) do |holder, gates|
      key = keys.find_by_holder(holder)
      if key.remove_gates!(gates) && self.respond_to?(:after_revoke_access)
        after_revoke_access(holder, gates)
      end
    end
    clear_key_cache
  end

  #
  # set access to gates
  #
  # sets the right bits on the specified holder(s) keys so that they can only open the specified gate(s)
  #
  # if the keys don't exist, they are created and set to exactly match the given bits.
  #
  # WARNING:
  # * no after_grant or after_revoke callbacks will be run
  # * this can lead to inconsistencies.
  #
  def set_access!(access_hash)
    process_access_hash(access_hash) do |holder, gates|
      key = keys.find_by_holder(holder)
      key.set_gates!(gates)
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
  # takes an access hash and validates it.
  # loops over the holder => gates pairs
  #
  def process_access_hash(access_hash)
    unless access_hash.respond_to?(:each_pair)
      raise ArgumentError.new('argument must be in the form {holder => gate}')
    end

    access_hash.each_pair do |holder, gates|
      unless gate_set.gates_exist?(gates)
        raise ArgumentError.new('one of these is not a gate %s' % gates.inspect)
      end
      holder = Holder[holder, self]
      gates = [gates] unless gates.is_a?(Array)

      yield(holder, gates)
    end
  end

  private

  ##
  ## CACHE
  ##

  def bitfield_for_holder(holder)
    self.class.gate_bitfield_cache[self.id] ||= {}
    self.class.gate_bitfield_cache[self.id][holder.code] ||= begin
      keys     = keys_for_holder(holder)
      gate_bitfield_for_keys(keys)
    end
  end

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
  def gate_bitfield_for_keys(keys)
    Key::gate_bitfield(keys)
  end

end
end
end
