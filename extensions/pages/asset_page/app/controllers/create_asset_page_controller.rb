class CreateAssetPageController < Page::CreateController

  before_filter :ensure_asset, only: :create

  def new
    @form_sections.unshift('file')
    @form_sections.delete('title')
    @multipart = true
    render_new_template
  end

  def create
    @asset = Asset.build asset_params
    @asset.validate!

    @page = build_new_page!
    @page.data = @asset
    @page[:title] = @asset.basename
    @page.save!

    redirect_to page_url(@page)
  end

  protected

  def page_type
    AssetPage
  end

  def asset_params
    params.require(:asset).permit(:uploaded_data).merge(user: current_user)
  end

  def ensure_asset
    if params[:asset].blank?
      warning :select_file_to_upload.t
      new
    end
  end
end

