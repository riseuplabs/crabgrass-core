class CreateAssetPageController < Pages::CreateController

  before_filter :ensure_asset, only: :create

  def new
    @form_sections.unshift('file')
    @form_sections.delete('title')
    @multipart = true
    render_new_template
  end

  def create
    @asset = Asset.build params[:asset].merge(user: current_user)
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

  def ensure_asset
    if params[:asset].blank?
      warning :select_file_to_upload.t
      new
    end
  end
end

