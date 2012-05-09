class Pages::AssetsController < Pages::SidebarsController

  permissions 'pages'
  guard_like :page, :edit
  before_filter :login_required

  def index
    render :partial => 'pages/assets/popup'
  end

  def update
    @page.cover = @asset
    @page.save!
    render :template => 'pages/reset_sidebar'
  end

  def create
    asset = @page.add_attachment! params[:asset], :cover => params[:use_as_cover], :title => params[:asset_title]
    current_user.updated(@page)
    respond_to do |format|
      format.json { render :json => {:url => asset.url} }
      format.html do
        responds_to_parent do
          render
        end
      end
    end
  end

  def destroy
    asset = Asset.find_by_id(params[:id])
    asset.destroy
    respond_to do |format|
      format.js {render :nothing => true }
      format.html do
        #flash_message(:success => "attachment deleted")
        success ['attachment deleted']
        redirect_to(page_url(@page))
      end
    end
  end

  protected

  def fetch_page
    super
    if @page and params[:id]
      @asset = @page.assets.find_by_id params[:id]
    end
  end

end
