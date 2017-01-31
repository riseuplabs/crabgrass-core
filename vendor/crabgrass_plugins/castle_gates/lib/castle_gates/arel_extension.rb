## required by CastleGates::Key.gate_bitfield
module Arel
  module Nodes
    class BitOr < Arel::Nodes::Function
    end
  end

  module Expressions
    def bit_or
      Nodes::BitOr.new([self], Nodes::SqlLiteral.new('bit_or_id'))
    end
  end

  module Visitors
    class DepthFirst < Arel::Visitors::Visitor
      alias :visit_Arel_Nodes_BitOr :function
    end

    class ToSql < Arel::Visitors::Reduce
      def visit_Arel_Nodes_BitOr o, collector
        aggregate "BIT_OR", o, collector
      end
    end
  end
end
