# = PathFinder::Builder
#
# An abstract super class of

# PathFinder::Mysql::Query
# PathFinder::Sphinx::Query
#
# This is called from FindByPath.

module PathFinder
  class Query

    public

    ##
    ## must be overridden by sub classes
    ##

    def initialize(path, options, klass)
      @options = options
    end

    def apply_filter(filter, args)
    end

    def add_attribute_constraint(attribute, value)
    end

    def add_access_constraint(access_hash)
    end

    def add_order(order_sql)
    end

    def cleanup_sort_column(column)
    end

    ##
    ## common utility
    ##

    def current_user
      @options[:current_user]
    end

    protected

    #
    # parses path into filters and applies each filter
    #
    # called by the initialize of each subclass
    #
    def apply_filters_from_path(path)
      ParsedPath.parse(path).filters.each do |filter, args|
        apply_filter(filter, args)
      end
    end

    #
    # page types can come in many forms:
    #
    #  wiki                -- page_type => wiki
    #  text                -- page_group => text
    #  text+wiki           -- page_group => text, page_type => wiki
    #  media-image         -- media_type => image
    #  media-image+gallery -- media_type => image, page_type => gallery
    #
    # this method parses the arg into this form and returns an
    # array [page_group, page_type, media_type]
    #
    def parse_page_type(arg)
      page_group = nil
      page_type = nil
      media_type = nil
      unless arg == 'all'
        if arg =~ /[\+\ ]/
          page_group, page_type = arg.split(/[\+\ ]/)
        elsif Page.is_page_group?(arg)
          page_group = arg
        elsif Page.is_page_type?(arg)
          page_type = arg
        end
        if page_group and page_group =~ /^media-(image|audio|video|document)$/
          media_type = page_group.sub(/^media-/,'')
          page_group = nil
        end
      end
      [page_group, page_type, media_type]
    end 

  end
end

