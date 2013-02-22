class Pages::AssetsController < Pages::SidebarsController

  permissions 'pages'
  guard :destroy => :may_admin_page?

  def index
    render :partial => 'pages/assets/popup', :content_type => 'text/html'
  end

  def update
    @page.cover = @asset
    @page.save!
    render :template => 'pages/reset_sidebar'
  end

  def create
    @asset = @page.add_attachment! params[:asset], :cover => params[:use_as_cover], :title => params[:asset_title]
    current_user.updated(@page)
  end

  protected

  def fetch_page
    super
    if @page and params[:id]
      @asset = @page.assets.find_by_id params[:id]
    end
  end

end
