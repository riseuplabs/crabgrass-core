class CreateAssetPageController < Pages::CreateController

  permissions 'pages', :object => 'page'

  def new
    @form_sections.unshift('file')
    @form_sections.delete('title')
    @multipart = true
    render_new_template
  end

  def create
    @asset = Asset.build params[:asset].merge(:user => current_user)
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

end

