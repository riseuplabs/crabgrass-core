module PathFinder
  module Sphinx
    class Query

      def initialize
        @with = []
        super
      end

      def apply_filter(filter, args)
        query_filter = filter.query_block || filter.sphinx_block
        if query_filter
          query_filter.call(self, *args)
        end
      end

      def add_attribute_constraint(attribute, value)
        @with << [attribute, value]
      end

      def add_access_contraint(access_hash)
        @with << [:access_ids, Page.access_ids_for(access_hash)]
      end

      def add_tag_constraint(tag)
        @conditions[:tags] ||= ""
        @conditions[:tags] += " #{tag}"
      end

      def add_order(order)
        @order << ' '
        @order << order
      end

      def add_text_filter(text)
        @search_text += " #{text}"
      end

      # filter on page type or types, and maybe even media flag too!
      def add_type_constraint(arg)
        page_group, page_type, media_type = parse_page_type(arg)

        if media_type
          @with << [:media, MEDIA_TYPE[media_type.to_sym]] # indexed as multi array of ints.
        elsif page_type
          @conditions[:page_type] = Page.param_id_to_class_name(page_type)
        elsif page_group
          @conditions[:page_type] = Page.class_group_to_class_names(page_group).join('|')
        else
          # we didn't find either a type or a group for arg
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

