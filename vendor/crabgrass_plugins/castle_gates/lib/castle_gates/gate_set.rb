#
# Every Castle class has a GateSet.
#
# Each GateSet has many gates.
#

module CastleGates
  class GateSet < HashWithIndifferentAccess

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
      if name.is_a? Gate
        name
      else
        self[name]
      end
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
        self.select(gate_names).bits
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
      gate_names = [gate_names] unless gate_names.is_a? Enumerable
      if gate_names == [:all]
        self
      else
        result = GateSet.new
        gate_names.each do |gate_name|
          if gate = self[gate_name]
            result[gate_name] = gate
          else
            raise ArgumentError.new 'bad gate name: %s' % gate_name
          end
        end
        result
      end
    end

    #
    # returns
    #
    def gates_exist?(gate_names)
      if gate_names == :all
        true
      elsif gate_names.is_a? Enumerable
        gate_names.inject(true) {|prior, gate| prior && self[gate]}
      #elsif gate_names.is_a? Gate
      #  self[gate_names.name]
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
