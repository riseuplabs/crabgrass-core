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
    # returns a bitmask composed of all the gates in the set.
    #
    def bits
      @bits ||= Gate.bits(self.values)
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

    private

    def id_taken?(id)
      self.values.detect do |gate|
        gate.id == id
      end
    end

  end
end
