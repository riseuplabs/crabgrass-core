## required by CastleGates::Key.gate_bitfield
module Arel
  class BitOr < Expression
    def function_sql; 'BIT_OR' end
  end

  module Attribute::Expressions
    def bit_or
      BitOr.new(self)
    end
  end
end
