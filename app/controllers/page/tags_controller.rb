class Page::TagsController < Page::SidebarsController
  helper 'page/tags'

  def index
    render partial: 'page/tags/popup', content_type: 'text/html'
  end

  def create
    @page.tag_list.add(params[:add], parse: true)
    @page.updated_by = current_user
    @page.tags_will_change!
    @page.save!
    # we do not update the popup yet - so let's just close it.
    close_popup
  end

  def destroy
    @page.tag_list.remove(params[:id])
    @page.updated_by = current_user
    @page.tags_will_change!
    @page.save!
    refresh_sidebar
  end
end
