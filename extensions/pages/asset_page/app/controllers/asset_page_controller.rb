class AssetPageController < Page::BaseController
  # before_action :fetch_asset

  def show
    redirect_to page_url(@page, action: 'new') if @asset.nil?
  end

  def edit; end

  def update
    if params[:asset]
      @asset.update_attributes! asset_params
      current_user.updated(@page)
      redirect_to page_url(@page)
    else
      raise ErrorMessage, :no_data_uploaded_label.t
    end
  end

  protected

  def asset_params
    params.require(:asset).permit(:uploaded_data).merge(user: current_user)
  end

  def fetch_data
    authorize @page
    @asset = @page.data if @page
  end

  def setup_options
    @options.show_assets = false
    @options.show_tabs = true if action?(:show, :edit)
  end
end
