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

    class ToSql < Arel::Visitors::Visitor
      def visit_Arel_Nodes_BitOr o, a
        "BIT_OR(#{o.distinct ? 'DISTINCT ' : ''}#{o.expressions.map { |x|
          visit x, a }.join(', ')})#{o.alias ? " AS #{visit o.alias, a}" : ''}"
      end
    end
  end
end
