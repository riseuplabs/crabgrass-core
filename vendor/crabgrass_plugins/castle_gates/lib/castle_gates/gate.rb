#
# A Gate is a protected thing.
#
# It belongs to a GateSet, which belongs to a Castle.
#
# ATTRIBUTES
#
# bit
#
#   Every castle has fixed set of gates in consecutive positions.
#   The gate id determines its position. The bit is a mask for this position.
#
#   For example
#     id    -->    bit
#     0     -->    0001   (reserved, see note in keys.rb)
#     1     -->    0010
#     2     -->    0100
#     3     -->    1000
#     and so on..
#
# fallback
#
#   when no key exists, is the gate open (true), or closed (false)
#
module CastleGates
  class Gate

    attr_accessor :name, :id, :bit, :label, :info

    def initialize(id, name, options={})
      self.name = name
      self.id = id
      self.label = options[:label]
      self.info = options[:info]
      if id == 0
        raise 'gate with id = 0 is reserved. start with 1.'
      else
        self.bit = 2 ** (id)
      end
    end

    #
    # return true if this gate may be opened by any of the keys
    #
    def opened_by?(gate_bitfield)
      # p({:bit => bit, :gate => gate_bitfield})
      (bit & ~gate_bitfield) == 0
    end

    def to_a
      [self]
    end
  end
end
