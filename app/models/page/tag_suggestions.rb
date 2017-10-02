#
# Page TagSuggestions
#
# Page::TagSuggestions 
#
# TagSuggestions are taken either from the group participations of a page or from the user tags 
#
#
#


class Page::TagSuggestions
  
  attr_reader :recent_tags, :popular_tags

  SUGGESTION_COUNT = 6

  def initialize(page, user)
    @tags = tags(page, user)
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

  def tags page, user 
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





