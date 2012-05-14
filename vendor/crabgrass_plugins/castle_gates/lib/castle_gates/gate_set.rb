#
# Every Castle class has a GateSet.
#
# Each GateSet has many gates.
#

module CastleGates
  class GateSet < Hash

    #
    # Add a gate to the set.
    #
    def add(gate)
      if self[gate.name]
        raise Exception.new('gate name "%s" already exists' % gate.name)
      elsif id_taken?(gate.id)
        raise Exception.new('gate id "%s" already exists' % gate.id)
      end
      self[gate.name] = gate
    end

    #
    # convert a gate name into a gate
    # e.g. gate_set.get(:front_door) ==> <gate>
    #
    def get(name)
      self[name]
    end

    #
    # Returns a bitmask composed of all or some of the gates in the set.
    #
    # if gate_names is nil, then all gates. otherwise, gate_names should
    # be an array of symbols that match gate names.
    #
    # OPTIMIZE: self.values ??
    #
    def bits(gate_names=nil)
      if gate_names.nil?
        @bits ||= begin
          gates = self.values
          gates.inject(0) do |bits_so_far, gate|
            bits_so_far | gate.bit
          end
        end
      else
        new_gate_set = self.select(gate_names)
        if new_gate_set.any?
          new_gate_set.bits
        end
      end
    end

    #
    # returns a bitmask composed of the default position for every gate in the gate_set,
    # for the particular holder.
    #
    # (position meaning open or closed)
    #
    # OPTIMIZE: self.values ??
    #
    def default_bits(holder)
      holder_name = Holder.get_definition(holder).name
      gates = self.values
      gates.inject(0) do |bits_so_far, gate|
        bits_so_far | gate.default_bit(holder_name)
      end
    end

    #
    # return true if any gates in this set may be opened by any of the keys
    #
    #def opened_by?(keys)
    #  (bits & ~keys.gate_bitfield) == 0
    #end

    #
    # given an array of gate names, return a GateSet that has just the gates
    # with names that match these symbols.
    #
    def select(gate_names)
      result = GateSet.new
      gate_names = [gate_names] unless gate_names.is_a? Enumerable
      gate_names.each do |gate_name|
        if gate = self[gate_name]
          result[gate_name] = gate
        end
      end
      result
    end

    #
    # returns
    #
    def gates_exist?(gate_names)
      if gate_names.is_a? Enumerable
        gate_names.inject(true) {|prior, gate| prior && self[gate]}
      else
        self[gate_names]
      end
    end

    private

    def id_taken?(id)
      self.values.detect do |gate|
        gate.id == id
      end
    end

  end
end
