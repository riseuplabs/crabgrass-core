class AssetPageController < Pages::BaseController
  #before_filter :fetch_asset
  permissions   'asset_page'

  def show
    if @asset.nil?
      redirect_to page_url(@page, action: 'new')
    end
  end

  def edit
  end

  def update
    unless params[:asset]
      raise_error :no_data_uploaded_label.t
    else
      @asset.update_attributes! params[:asset].merge(user: current_user)
      current_user.updated(@page)
      redirect_to page_url(@page)
    end
  end


  protected

  def fetch_data
    @asset = @page.data if @page
  end

  def setup_options
    @options.show_assets = false
    if action?(:show, :edit)
      @options.show_tabs   = true
    end
  end

end
