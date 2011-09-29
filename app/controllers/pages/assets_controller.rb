class Pages::AssetsController < Pages::SidebarsController

  permissions 'pages', :verb => :edit # the assets_permission file is for the assets controller not under pages.
  before_filter :login_required
  helper 'pages/assets'

  def index
    render :partial => 'pages/assets/popup'
  end

  def update
    @page.cover = @asset
    @page.save!
    render :template => 'pages/reset_sidebar'
  end

  ## TODO: use iframe trick to make this ajaxy
  def create
    asset = @page.add_attachment! params[:asset], :cover => params[:use_as_cover], :title => params[:asset_title]
    @page.update_attribute :updated_at, Time.now
    #flash_message :object => asset
    redirect_to page_url(@page)
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
