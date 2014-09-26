
class AssetPageHistoryController < Pages::BaseController

  guard index: :may_show_page?, destroy: :may_edit_page?
  helper 'asset_page'

  def index
  end

  def destroy
    asset_version = @asset.versions.find_by_version(params[:id])
    asset_version.destroy
    render(:update) do |page|
      page.hide "asset_#{asset_version.asset_id}_version_#{asset_version.version}"
    end
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
