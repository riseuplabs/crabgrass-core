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
# NOTE: @conditions is a hash, @with is an array.
#

class PathFinder::Sphinx::Query < PathFinder::Query

  ##
  ## OVERRIDES
  ##

  def initialize(path, options, klass)
    super

    @original_path = path
    @original_options = options
    @klass = klass # What are we searching Pages or Posts?

    @with = []
    if options[:group_ids] or options[:user_ids] or options[:public]
      @with << access_limit(
        :public => options[:public],
        :group_ids => options[:group_ids],
        :user_ids => options[:user_ids]
      )
    end
    if options[:secondary_group_ids] or options[:secondary_user_ids]
      @with << access_limit(
        :group_ids => options[:secondary_group_ids],
        :user_ids => options[:secondary_user_ids]
      )
    end
    if options[:site_ids]
      @with << access_limit(
        :site_ids => options[:site_ids]
      )
    end

    @without      = {}
    @conditions   = {}
    @order        = ""
    @search_text  = ""
    @per_page    = options[:per_page] || PathFinder.default_pagination_size
    @page        = options[:page] || 1

    apply_filters_from_path(path)
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
    # the default sort is '@relevance DESC', but this can create rather odd
    # results because you might get relevent pages from years ago. So, if there
    # is no explicit order set, we want to additionally sort by page_updated_at.
    if @order.blank?
      @sort_mode = :extended
      @order = "@relevance DESC, page_updated_at DESC"
    end

    # puts "PageTerms.search #{@search_text.inspect}, :with => #{@with.inspect}, :without => #{@without.inspect}, :conditions => #{@conditions.inspect}, :page => #{@page.inspect}, :per_page => #{@per_page.inspect}, :order => #{@order.inspect}, :include => :page"

    # 'with' is used to limit the query using an attribute.
    # 'conditions' is used to search for on specific fields in the fulltext index.
    # 'search_text' is used to search all the fulltext index.
    page_terms = PageTerms.search @search_text,
      :page => @page,   :per_page => @per_page,  :include => :page,
      :with => @with,   :without => @without, :conditions => @conditions,
      :order => @order, :sort_mode => @sort_mode

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
    PageTerms.search_for_ids(@search_text, :with => @with, :without => @without,
      :page => @page, :per_page => @per_page, :conditions => @conditions,
      :order => @order, :include => :page).size
  rescue ThinkingSphinx::ConnectionError, Riddle::ConnectionError
    fallback.count
  end

  def fallback
    PathFinder::Mysql::Query.new(@original_path, @original_options, @klass)
  end

  ##
  ## utility methods called by SearchFilter classes
  ##

  def add_attribute_constraint(attribute, value)
    @with << [attribute, value]
  end

  def add_access_constraint(access_hash)
    @with << access_limit(access_hash)
  end

  def add_public
    @with << access_limit(:public => true)
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

  private

  #
  # creates appropriate structures to pass to sphinx ':with'
  # attribute filter, using the attribute 'access_ids' in order to
  # encode permissions.
  #
  # we use an array for @with (rather than a hash), so that we
  # can have multiple constraints on the same key. See README_GEMS
  # for details on this hackery.
  #
  def access_limit(access_hash)
    ['access_ids', Page.access_ids_for(access_hash)]
  end
end

