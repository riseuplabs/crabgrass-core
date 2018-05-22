class AssetPageVersionsController < Page::BaseController
  helper 'asset_page'

  def index
    authorize @page, :show?
  end

  def create
    authorize @page, :update?
    @asset.generate_thumbnails
  end

  def destroy
    authorize @page, :update?
    @asset_version = @asset.versions.find_by_version(params[:id])
    @asset_version.destroy
    current_user.updated(@page)
  end

  protected

  def fetch_data
    @asset = @page.data if @page
  end

  def setup_options
    @options.show_assets = false
    @options.show_tabs   = true
  end
end
