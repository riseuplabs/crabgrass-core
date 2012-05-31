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
# default
#
#   if default is set to true, then all holders have access to this gate by default.
#   (ie, they will have access unless explicitly revoked).
#
#   if default is set to a symbol or array of symbols, then only holders with names
#   that match the symbols will have default access.
#
#   when new keys are created, they use these defaults.
#
# fallback
#
#   when no key exists, is the gate open (true), or closed (false)
#
module CastleGates
  class Gate

    attr_accessor :name, :id, :bit, :default, :label, :info

    def initialize(id, name, options={})
      self.name = name
      self.id = id
      self.default = options[:default_open]
      self.label = options[:label]
      self.info = options[:info]
      if id == 0
        raise 'gate with id = 0 is reserved. start with 1.'
      else
        self.bit = 2 ** (id)
      end
    end

    #
    # Returns the bit of this gate if the specified holder should have
    # access by default, regardless of what key records exist in the database.
    #
    # This does not change, and is requested frequently, so we cache it.
    # (although probably doing this is not a great speedup)
    #
    def default_bit(holder_name)
      @default_bit_map ||= {}
      @default_bit_map[holder_name] ||= begin
        if default === true
          bit
        elsif default == holder_name
          bit
        elsif default.is_a?(Array) && default.include?(holder_name)
          bit
        else
          0
        end
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
