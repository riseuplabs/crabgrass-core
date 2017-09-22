class Page::TagsController < Page::SidebarsController
  helper 'page/tags'
  SUGGESTION_COUNT = 6

  def index
    if @page.owner_type == 'Group'
      tags = Page.tags_for_group(@page.owner, current_user) 
    else
      tags = current_user.tags 
    end
    tags -= @page.tags 
    @recent_tags = tags.select { |t| t[:taggings_count] > 0 }.sort_by { |t| -t[:id] }.take(SUGGESTION_COUNT) 
    tags -= @recent_tags
    tags = ActsAsTaggableOn::Tag.where(id: tags.map(&:id))
    @popular_tags = tags.where.not(taggings_count: 0).most_used(SUGGESTION_COUNT) # should not be necessary to ask for taggings_count: 0
    render partial: 'page/tags/popup', content_type: 'text/html'
  end

  def create
    @page.tag_list.add(params[:add], parse: true)
    @page.updated_by = current_user
    @page.tags_will_change!
    @page.save!
    if params[:commit]
      close_popup
    else 
      refresh_sidebar
    end
  end

  def destroy
    @page.tag_list.remove(params[:id])
    @page.updated_by = current_user
    @page.tags_will_change!
    @page.save!
    refresh_sidebar
  end
end
