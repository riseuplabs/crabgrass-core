class AssetPageController < Page::BaseController
  #before_filter :fetch_asset

  def show
    if @asset.nil?
      redirect_to page_url(@page, action: 'new')
    end
  end

  def edit
  end

  def update
    unless params[:asset]
      raise ErrorMessage, :no_data_uploaded_label.t
    else
      @asset.update_attributes! asset_params
      current_user.updated(@page)
      redirect_to page_url(@page)
    end
  end


  protected

  def asset_params
    params.require(:asset).permit(:uploaded_data).merge(user: current_user)
  end

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
