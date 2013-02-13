## required by CastleGates::Key.gate_bitfield
module Arel
  module Nodes
    class BitOr < Arel::Nodes::Function
    end
  end

  module Attribute::Expressions
    def bit_or
      Nodes::BitOr.new(self)
    end
  end
end
