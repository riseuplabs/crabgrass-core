#
# A Gate is a protected thing.
# It belongs to a GateSet, which belongs to a Castle.
#
# Every castle has fixed set of gates in consecutive positions.
# The gate id determines its position. The bit is a mask for this position.
#
# For example
#
#   id    -->    bit
#   0     -->    0000
#   1     -->    0001
#   2     -->    0010
#   3     -->    0100
#   and so on..
#

module CastleGates
  class Gate

    attr_accessor :name, :id, :bit

    def initialize(options)
      self.name = options[:name]
      self.id = options[:id]
      if id == 0
        self.bit = 0
      else
        self.bit = 2 ** (id-1)
      end
    end

    #
    # return true if this gate may be opened by any of the keys
    #
    def opened_by?(keys)
      p [bit, keys.gate_bitfield]
      (bit & ~keys.gate_bitfield) == 0
    end

    #
    # takes a gate or array of gates and creates a bit mask for all
    # of them.
    #
    def self.bits(gates)
      gates.to_a.inject(0) do |bits_so_far, gate|
        bits_so_far | gate.bit
      end
    end

    def to_a
      [self]
    end
  end
end
