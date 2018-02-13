#
# Page::TagSuggestions
#
# TagSuggestions are used
# * when editing tags via the sidebar.
# * in the search filter for page lists.
#
# The N most recent tags will be suggested as "Recent tags" and the most popular
# tags as "Popular tags"

# If a page is accessible by group(s), TagSuggestions are taken from all pages of
# those groups accessible to the current_user.
# If a page is not accessible by groups, TagSuggestions are taken from the
# current_user tags.
#
# The attribute @tags holds all tags which could be suggested. We currently do
# not use those tags (we just display either recent or popular tags).
# We will need them for an autocomplete function for tags which will hopefully
# be implemented soon.


class Page::TagSuggestions

  attr_reader :all

  SUGGESTION_COUNT = 6

  def initialize(page_or_sources, current_user)
    @current_user = current_user
    @page = page_or_sources if page_or_sources.is_a?(Page)
    sources = sources_for page_or_sources
    @all = tags_from_sources(sources) - tags_already_used
  end

  def recent
    all.select { |t| t[:taggings_count] > 0 }.sort_by { |t| -t[:id] }.take(SUGGESTION_COUNT)
  end

  def popular
    ActsAsTaggableOn::Tag.where(id: (all - recent))
      .where.not(taggings_count: 0)
      .most_used(SUGGESTION_COUNT)
  end

  protected

  attr_reader :page, :current_user

  def sources_for(page_or_sources)
    if page_or_sources.is_a? Page
      sources_for_page(page_or_sources)
    else
      Array page_or_sources
    end
  end

  def sources_for_page(page)
    Array(page.group || page.groups.presence || current_user)
  end

  def tags_from_sources(sources)
    sources.map{|source| tags_from(source)}.flatten.compact.uniq
  end

  def tags_already_used
    page ? page.tags : []
  end

  def tags_from(source)
    if source.is_a? Group
      tags_for_group(source)
    elsif source.is_a? User
      source.tags if source == current_user
    end
  end

  #
  # tags are potentially sensitive information. we don't want to show
  # visitors to a group all the tags from all the pages for that group.
  #
  # we ONLY want to show them tags for pages that the group owns and
  # that the current_user has access to see.
  #
  # So, in order to do that, we need to use page_terms. Currently, this
  # query includes pages the group has access to but is not the owner
  # of. It would be slower to limit it to owned pages, so we don't yet.
  #
  def tags_for_group(group)
    access_condition = <<-EOSQL
      MATCH(page_terms.access_ids, page_terms.tags)
      AGAINST (? IN BOOLEAN MODE)
    EOSQL
    ActsAsTaggableOn::Tag.select("tags.*, count(name) as count").
      joins(:taggings).
      where("taggings.taggable_type = 'Page'").
      joins("INNER JOIN page_terms ON page_terms.page_id = taggings.taggable_id").
      where([access_condition, access_filter(group)]).
      group(:name).
      order(:name)
  end

  def access_filter(group)
    if current_user and current_user.may?(:edit, group)
      # current_user can see all the group's pages
      Page::Terms.access_filter_for(group)
    elsif current_user.present?
      # current_user can see public pages OR pages it has access to.
      format '(%s) (%s)',
        Page::Terms.access_filter_for(group, :public),
        Page::Terms.access_filter_for(group, current_user)
    else
      # only show public pages
      Page::Terms.access_filter_for(group, :public)
    end
  end
end
