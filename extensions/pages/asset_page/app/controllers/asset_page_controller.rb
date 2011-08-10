class AssetPageController < Pages::BaseController
  before_filter :fetch_asset
  stylesheet    'asset'
  permissions   'asset_page'

  def show
    if @asset.nil?
      redirect_to page_url(@page, :action => 'new')
    end
  end

  def new
  end

  def create
    unless params[:asset][:uploaded_data].any?
      @page.errors.add_to_base I18n.t(:no_data_uploaded)
      raise ActiveRecord::RecordInvalid.new(@page)
    end
    asset = Asset.build params[:asset]
    @page.data = asset
    current_user.updated(@page)
    @page.save!
    redirect_to page_url(@page)
  end

  def edit
  end

  def update
    @asset.update_attributes params[:asset]
    if @asset.valid?
      current_user.updated(@page)
      redirect_to(page_url(@page))
    else
      flash_message_now :object => @page
    end
  end

  # xhr request
  def generate_preview
    @asset.generate_thumbnails
    render :update do |page|
      page.replace_html 'preview_area', asset_link_with_preview(@asset)
    end
  end

  protected

  def fetch_asset
    @asset = @page.data if @page
  end

  def setup_options
    @options.show_assets = false
    if action?(:show, :edit, :history)
      @options.show_tabs   = true
    end
  end

  #def build_page_data
  #  unless params[:asset][:uploaded_data].any?
  #    @page.errors.add_to_base I18n.t(:no_data_uploaded)
  #    raise ActiveRecord::RecordInvalid.new(@page)
  #  end
  #
  #  asset = Asset.build params[:asset]
  #  @page[:title] = asset.basename unless @page[:title].any?
  #  asset
  #end
end
