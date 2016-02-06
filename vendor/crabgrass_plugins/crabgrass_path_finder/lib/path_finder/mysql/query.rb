# = PathFinder::Mysql:Query
#
# Concrete subclass of PathFinder::Query
#
# == Usage:
#
# This class generates the SQL and makes the call to find_by_sql.
# It is called from find_by_path in PathFinder::FindByPath. Look there
# for an example how to use it.
#
# == Resolving Permissions
#
# It uses a fulltext index on page_terms in order to resolve permissions for pages.
# This bypasses potentially really hairy four-way joins on user_participations
# and group_participations tables.
# (not to mention a potential 5th,6th,7th joins for tags, ugh!)
#
# An example query:
#
#  SELECT * FROM pages
#  JOIN page_terms ON pages.id = page_terms.page_id
#  WHERE
#    MATCH(page_terms.access_ids)
#    AGAINST('+(0001 0011 0081 0082) +0081' IN BOOLEAN MODE)
#
# * this is an inner join, because *every* page should
#   have a corresponding page_term.
# * page_term.access_ids is a text column with a fulltext index.
# * the format of the values in access_ids is thus:
#   * user ids are prefixed with 1
#   * group ids are prefixed with 8
#   * every id is at least four characters in length,
#     padded with zeros if necessary.
#   * if page is public, id 0001 is present.
#
# So, suppose the current user was id 1, and they were
# members of groups 1 and 2.
#
# To find all the pages of group 1 that current_user may access:
#
#    (current_user.id OR public OR current_user.all_group_ids) AND group.id
#
# In fulltext boolean mode search on access_ids, this becomes:
#
#    +(0011 0001 0081 0082) +0081
#
# The first part of this condition is called the access_me_clause. This is where we
# resolve the question "what does current user have access to?". This clause is
# based entirely on the current_user variable.
#
# The next AND clause is called the access_target_clause. This is where we ask "who's
# pages are we searching for?". This clause is based entirely on what options
# are used (ie options_for_group() or options_for_user())
#
# There can be additional AND clauses. These are called access_filter_clauses.
# This is for additional limits that pop up in the path itself. It is based
# entirely on what is in the filter path.
#

class PathFinder::Mysql::Query < PathFinder::Query

  ##
  ## OVERRIDES
  ##

  def initialize(path, options, klass)
    super

    @relation = klass # something to start with

    @access_filter_clause = [] # to be used by path filters

    ## page stuff
    @order       = []
    @tags        = []
    @flow        = options[:flow]
    @date_field  = 'created_at'

    # magic will_paginate paginating (count required)
    @per_page    = options[:per_page]
    @page        = options[:page]
    # limiting   (count not required)
    @limit       = nil
    @offset      = nil
    @include     = options[:include]

    select options[:select] if options[:select]

    # klass the find/paginate/... was send to and thus of the objects we return.
    @klass = klass

    apply_filters_from_path(path)
    apply_fulltext_filter
    apply_flow_filter
  end

  def apply_filter(filter, args)
    query_filter = filter.query_block || filter.mysql_block
    if query_filter
      query_filter.call(self, *args)
    end
  end

  ##
  ## FINDERS
  ##

  def find
    final_relation
  end

  def paginate
    final_relation.paginate page: @page, per_page: @per_page
  end

  def count
    final_relation.count
  end

  def ids
    final_relation.pluck('pages.id')
  end

  ##
  ## utility methods called by SearchFilter classes
  ##

  def add_sql_condition(*args)
    [:user_participations, :group_participations].each do |j|
      joins(j) if /#{j.to_s}\./ =~ args.first
    end
    where(*args)
  end

  # and a condition based on an attribute of the page
  def add_attribute_constraint(attribute, value)
    where("pages.#{attribute} = ?", value)
  end

  # add a condition based on the fulltext access field
  def add_access_constraint(access_hash)
    @access_filter_clause << "+(#{Page.access_ids_for(access_hash).join(' ')})"
  end

  def add_public
    add_access_constraint(public: true)
  end

  def add_tag_constraint(tag)
    @tags << "+" + Page.searchable_tag_list([tag]).first
  end

  def set_flow_constraint(flow)
    @flow = flow
  end

  def add_order(order_sql)
    if @order # if set to nil, this means we must skip sorting
      if order_sql =~ /\./
        @order << order_sql
      else
        @order << "#{@klass.table_name}.#{order_sql}"
      end
    end
  end

  def add_limit(limit_count)
    @limit = limit_count
  end

  def cleanup_sort_column(column)
    case column
      when 'views' then 'views_count'
      when 'stars' then 'stars_count'
      # MISSING: when 'edits' then 'edits_count'
      when 'contributors' then 'contributors_count'
      when 'posts' then 'posts_count'
      else column
    end
    return column.gsub(/[^[:alnum:]]+/, '_')
  end

  def add_most_condition(what, num, unit)
    unit=unit.downcase.pluralize
    name= what=="edits" ? "contributors" : what
    num.gsub!(/[^\d]+/, ' ')
    if unit=="months"
      unit = "days"
      num = num.to_i * 31
    elsif unit=="years"
      unit = "days"
      num = num.to_i * 365
    end
    if unit=="days"
      joins :dailies
      where "dailies.created_at > UTC_TIMESTAMP() - INTERVAL %s DAY" % num
      @order << "SUM(dailies.#{what}) DESC"
      select "pages.*, SUM(dailies.#{what}) AS #{name}_count"
    elsif unit=="hours"
      joins :hourlies
      where "hourlies.created_at > UTC_TIMESTAMP() - INTERVAL %s HOUR" % num
      @order << "SUM(hourlies.#{what}) DESC"
      select "pages.*, SUM(hourlies.#{what}) AS #{name}_count"
    else
      return
    end
  end

  # filter on page type or types, and maybe even media flag too!
  def add_type_constraint(arg)
    page_group, page_type, media_type = parse_page_type(arg)

    if media_type
      # safe because media_type is limited by parge_page_type
      where "pages.is_#{media_type} = ?", true
    elsif page_type
     where 'pages.type = ?',
       Page.param_id_to_class_name(page_type) # eg 'RateManyPage'
    elsif page_group
      where 'pages.type IN (?)',
        Page.class_group_to_class_names(page_group) # eg ['WikiPage','SurveyPage']
    else
      # we didn't find either a type or a group for arg
    end
  end

  private

  def where(*args)
    @relation = @relation.where(*args)
  end

  def joins(*args)
    @relation = @relation.joins(*args)
  end

  def select(*args)
    @relation = @relation.select(*args)
  end

  def apply_fulltext_filter
    fulltext_filter = access_filters(@options)
    fulltext_filter += [@access_filter_clause, @tags]
    fulltext_filter.flatten!.compact!

    if fulltext_filter.any?
      # it is absolutely vital that we MATCH against both access_ids and tags,
      # because this is how the index is specified.
      joins :page_terms
      where "MATCH(page_terms.access_ids, page_terms.tags) AGAINST (? IN BOOLEAN MODE)",
        fulltext_filter.join(' ')
    end
  end

  def access_filters(options)
    ## page_terms access clauses
    ## (within each clause, the values are OR'ed, but the clauses are AND'ed
    ##  together in the query).
    secondary_options = {
      group_ids: options[:secondary_group_ids],
      user_ids: options[:secondary_user_ids]
    }
    [
      access_filter(options.slice(:group_ids, :user_ids, :public)),
      access_filter(secondary_options),
      access_filter(options.slice(:site_ids))
    ]
  end

  def access_filter(options)
    active_options = options.select{|k,v| v.present?}
    if active_options.present?
      "+(%s)" % Page.access_ids_for(active_options).join(' ')
    end
  end

  ##
  ## private guts for building the actual query
  ##

  def final_relation
    order = sql_for_order
    @relation
      .order(order)
      .includes(@include)
      .limit(@limit)
      .offset(@offset)
      .group(sql_for_group(order))
      .having(sql_for_having(order))
  end

  # TODO: make this more generall so it works with all aggregation functions.
  def sql_for_group(order_string)
    if match = /SUM\(.*\)/.match(order_string)
      "pages.id"
    end
  end

  # TODO: make this more generall so it works with all aggregation functions.
  def sql_for_having(order_string)
    if match = /SUM\(.*\)/.match(order_string)
      "#{match} > 0"
    end
  end

  def sql_for_order
    if @order.nil?
      return nil
    else
      if @order.empty? and SearchFilter['descending']
        apply_filter(SearchFilter['descending'], 'updated-at')
      end
      if @order.empty?
        return nil
      else
        return @order.reject(&:blank?).join(', ')
      end
    end
  end

  def apply_flow_filter
    return if @flow.blank?
    return unless @klass == Page
    where flow: Array(@flow).map{|f| FLOW[f]}
  end

end
