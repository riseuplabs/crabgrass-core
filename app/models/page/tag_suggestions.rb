#
# Page::TagSuggestions 
#
# TagSuggestions are used when editing tags via the sidebar. 
# 
# The N most recent tags will be suggested as "Recent tags" and the most popular 
# tags as "Popular tags"

# If a page is accessible by group(s), TagSuggestions are taken from all pages of
# those groups accessible to the user. 
# If a page is not accessible by groups, TagSuggestions are taken from the user
# tags. 
# 
# The attribute @tags holds all tags which could be suggested. We currently do
# not use those tags (we just display either recent or popular tags). 
# We will need them for an autocomplete function for tags which will hopefully 
# be implemented soon.


class Page::TagSuggestions
  
  attr_reader :tags, :recent_tags, :popular_tags

  SUGGESTION_COUNT = 6

  def initialize(page, user)
    @tags = prepare_tags(page, user)
    @recent_tags = prepare_recent_tags
    @popular_tags = prepare_popular_tags
  end

  protected

  def prepare_recent_tags 
    @tags.select { |t| t[:taggings_count] > 0 }.sort_by { |t| -t[:id] }.take(SUGGESTION_COUNT)
  end

  def prepare_popular_tags
    tags = ActsAsTaggableOn::Tag.where(id: @tags.map(&:id))
    tags = tags.where.not(taggings_count: 0).most_used(SUGGESTION_COUNT) 
    tags -= @recent_tags
  end

  def prepare_tags page, user 
    tags = []
    if page.owner_type == 'Group'
      tags = Page.tags_for_group(page.owner, user)
    elsif page.group_participations.any?
      page.group_participations.each do |participation|
        group = Group.find_by_id(participation.group_id)
        tags += Page.tags_for_group(group, user)
      end
    else
      tags = user.tags
    end
    tags -= page.tags
  end

end





