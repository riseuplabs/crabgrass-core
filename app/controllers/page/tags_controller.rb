class Page::TagsController < Page::SidebarsController
  before_action :authorize_page
  helper 'page/tags'
  SUGGESTION_COUNT = 6

  def index
    @tag_suggestions = Page::TagSuggestions.new(@page, current_user)
    render partial: 'page/tags/popup', content_type: 'text/html'
  end

  def create
    @page.tag_list.add(params[:add], parse: true, parser: Page::TagDowncaseParser)
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

  def authorize_page
    authorize @page, :update?
  end
end
