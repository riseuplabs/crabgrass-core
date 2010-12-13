module PathFinder
  module Sphinx
    class Query

      def initialize
        @with = []
        super
      end

      def add_attribute_constraint(attribute, value)
        @with << [attribute, value]
      end
   
      def add_access_contraint(access_hash)
        @with << [:access_ids, Page.access_ids_for(access_hash)]
      end

      def add_order(order)
        @order << ' '
        @order << order
      end

      def add_text_filter(text)
        @search_text += " #{text}"
      end

      end

      def cleanup_sort_column(column)
        column = case column
          when 'updated_at' then 'page_updated_at'
          when 'created_at' then 'page_created_at'
          when 'views' then 'views_count'
          when 'stars' then 'stars_count'
          # MISSING: when 'edits' then 'edits_count' missing
          # MISSING: when 'contributors' then 'contributors_count'
          # MISSING: when 'posts' then 'posts_count'
          else column
        end
        return column.gsub(/[^[:alnum:]]+/, '_')
      end

    end
  end
end

