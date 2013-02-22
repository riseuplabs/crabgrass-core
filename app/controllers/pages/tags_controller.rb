class Pages::TagsController < Pages::SidebarsController

  permissions 'pages'
  helper 'pages/tags'

  def index
    render :partial => 'pages/tags/popup', :content_type => 'text/html'
  end

  def create
    @page.tag_list.add(params[:add], :parse => true)
    @page.updated_by = current_user
    @page.tags_will_change!
    @page.save!
    close_popup
  end

  def destroy
    @page.tag_list.remove(params[:id])
    @page.updated_by = current_user
    @page.tags_will_change!
    @page.save!
    render :nothing => true
  end

end
