#
# This defines the sphinx PathFinder::Query.
# Filters in extensions/search_filters use this class to build the query.
# This query is also responsible for making the sphinx search call.
#
# Attribute filters versus conditions
#
# In sphinx, an attribute is indexed separately had is numeric only. You
# can do more things with attributes, like search for ranges or use boolean
# logic.
#
# When you want to apply an attribute filter, you use @with.
#
# When you want to search on a string field, you use @conditions.
#
# These fields are defines as sphinx attributes, and should use
# @with instead of @conditions:
#
# :sphinx_internal_id, :class_crc, :sphinx_deleted, :title_sort,
# :page_type_sort, :created_by_login_sort, :updated_by_login_sort,
# :owner_name_sort, :page_created_at, :page_updated_at, :views_count,
# :created_by_id, :updated_by_id, :resolved, :stars_count, :access_ids,
# :media
#
#

class PathFinder::Sphinx::Query < PathFinder::Query

  ##
  ## OVERRIDES
  ##

  def initialize(path, options, klass)
    super

    @original_path = path
    @original_options = options.dup
    @klass = klass # What are we searching Pages or Posts?

    @with = {}

    add_access_constraint options.slice(:public, :group_ids, :user_ids)
    add_access_constraint group_ids: options[:secondary_group_ids],
      user_ids: options[:secondary_user_ids]
    add_access_constraint site_ids: options[:site_ids]

    @without      = {}
    @conditions   = {}
    @order        = ""
    @search_text  = ""
    @per_page    = options[:per_page] || PathFinder.default_pagination_size
    @page        = options[:page] || 1
    @flow        = options.delete(:flow)

    apply_filters_from_path(path)
    apply_flow
    @order = @order.presence
  end

  def apply_filter(filter, args)
    query_filter = filter.query_block || filter.sphinx_block
    if query_filter
      query_filter.call(self, *args)
    end
  end

  ##
  ## FINDERS
  ##

  def search
    # the default sort is 'weight() DESC', but this can create rather odd
    # results because you might get relevent pages from years ago. So, if there
    # is no explicit order set, we want to additionally sort by page_updated_at.
    if @order.blank?
      @sort_mode = :extended
      @order = "weight() DESC, page_updated_at DESC"
    end

    #puts "PageTerms.search #{@search_text.inspect}, :with => #{@with.inspect}, :without => #{@without.inspect}, :conditions => #{@conditions.inspect}, :page => #{@page.inspect}, :per_page => #{@per_page.inspect}, :order => #{@order.inspect}, :include => :page"

    # 'with' is used to limit the query using an attribute.
    # 'conditions' is used to search for on specific fields in the fulltext index.
    # 'search_text' is used to search all the fulltext index.
    options = search_options sort_mode: @sort_mode
    page_terms = PageTerms.search @search_text, options

    # page_terms has all of the will_paginate magic included, it just needs to
    # actually have the pages, which we supply with page_terms.replace(pages).
    pages = []
    page_terms.each do |pt|
      pages << pt.page unless pt.nil?
      # Why might pt be nil? If the PageTerms was destroyed but sphinx has
      # not been reindex. This should not ever happen when things are working,
      # but sometimes it does, and if it does we don't want to bomb out.
    end
    page_terms.replace(pages)
    return page_terms
  end

  def find
    search
  rescue ThinkingSphinx::ConnectionError, Riddle::ConnectionError
    fallback.find
  end

  def paginate
    search # sphinx search *always* paginates
  rescue ThinkingSphinx::ConnectionError, Riddle::ConnectionError
    fallback.paginate
  end

  def count
    PageTerms.search_for_ids(@search_text, search_options).size
  rescue ThinkingSphinx::ConnectionError, Riddle::ConnectionError
    fallback.count
  end

  def search_options(options = {})
    options.reverse_merge page: @page,
      per_page: @per_page,
      include: :page,
      with_all: @with,
      without_all: @without,
      conditions: @conditions,
      order: @order
  end

  def fallback
    PathFinder::Mysql::Query.new(@original_path, @original_options, @klass)
  end

  ##
  ## utility methods called by SearchFilter classes
  ##

  def add_attribute_constraint(attribute, value)
    return if value.blank?
    @with[attribute] ||= []
    @with[attribute] << [value]
  end

  def add_access_constraint(access_hash)
    add_attribute_constraint 'access_ids', access_limit(access_hash)
  end

  def add_public
    add_access_constraint public: true
  end

  def add_tag_constraint(tag)
    @conditions[:tags] ||= ""
    @conditions[:tags] << " "
    @conditions[:tags] << Page.searchable_tag_list([tag]).first
  end

  def add_order(order)
    @order << ' '
    @order << order
  end

  #
  # limit is not compatible with pagination.
  # i am not sure we even want to support it.
  #
  def add_limit(limit)
    @per_page = limit
    @page = 1
  end

  #def add_offset(limit, offset)
  #  @per_page = limit
  #  @page = ((offset.to_f/limit.to_f) + 1).floor.to_i
  #end

  def add_text_filter(text)
    @search_text += Riddle::Query.escape " #{text}"
  end

  # filter on page type or types, and maybe even media flag too!
  def add_type_constraint(arg)
    page_group, page_type, media_type = parse_page_type(arg)

    if media_type
      # indexed as multi array of ints.
      add_attribute_constraint :media, MEDIA_TYPE[media_type.to_sym]
    elsif page_type
      @conditions[:page_type] = Page.param_id_to_class_name(page_type)
    elsif page_group
      @conditions[:page_type] = Page.class_group_to_class_names(page_group).join('|')
    else
      # we didn't find either a type or a group for arg
    end
  end

  def set_flow_constraint(flow)
    @flow = flow
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

  private

  #
  # creates appropriate structures to pass to sphinx ':with'
  # attribute filter, using the attribute 'access_ids' in order to
  # encode permissions.
  #
  # we use an array of arrays for @with and feed it to with_all.
  # This way we can have multiple constraints on the same key.
  # For details see:
  # https://github.com/riseuplabs/crabgrass-core/pull/306
  #
  def access_limit(access_hash)
    real_access = access_hash.select{|_k,v| v.present?}
    [Page.access_ids_for(real_access)]
  end

  #
  # possible flows are :normal, :deleted, :announcement.
  # symbols can converted to integers via FLOW constant
  #
  def apply_flow
    if @flow
      add_attribute_constraint('flow', FLOW[@flow])
    end
  end

end
