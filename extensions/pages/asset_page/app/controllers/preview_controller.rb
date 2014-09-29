class PreviewController < Pages::BaseController
  permission 'asset_page'

  def create
    @asset.generate_thumbnails
    render :update do |page|
      page.replace_html 'preview_area', asset_link_with_preview(@asset)
    end
  end

  protected

  def fetch_data
    @asset = @page.data if @page
  end
end
