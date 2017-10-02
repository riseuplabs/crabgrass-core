class Page::TagsController < Page::SidebarsController
  helper 'page/tags'
  SUGGESTION_COUNT = 6

  def index
    tag_suggestions = Page::TagSuggestions.new(@page, current_user)
    @recent_tags = tag_suggestions.recent_tags
    @popular_tags = tag_suggestions.popular_tags    
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
