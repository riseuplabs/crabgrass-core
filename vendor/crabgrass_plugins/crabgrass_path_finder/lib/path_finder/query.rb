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

  end
end

