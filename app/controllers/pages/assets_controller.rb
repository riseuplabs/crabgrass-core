class Pages::AssetsController < Pages::SidebarsController

  helper 'pages/assets'

  def index
    render partial: 'pages/assets/popup', content_type: 'text/html'
  end

  def update
    @page.cover = @asset
    @page.save!
    render template: 'pages/reset_sidebar'
  end

  def create
    @asset = @page.add_attachment! asset_params
    current_user.updated(@page)
  end

  protected

  def fetch_page
    super
    if @page and params[:id]
      @asset = @page.assets.find_by_id params[:id]
    end
  end

  def asset_params
    params.require(:asset).permit(:uploaded_data)
  end

end
