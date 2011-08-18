class AssetPageController < Pages::BaseController
  #before_filter :fetch_asset
  #stylesheet    'asset'
  permissions   'asset_page'

  def show
    if @asset.nil?
      redirect_to page_url(@page, :action => 'new')
    end
  end

  def new
  end

  def edit
  end

  def update
    unless params[:asset]
      raise_error :no_data_uploaded_label.t
    else
      @asset.update_attributes! params[:asset].merge(:user => current_user)
      current_user.updated(@page)
      redirect_to page_url(@page)
    end
  end

  # xhr request
  def generate_preview
    @asset.generate_thumbnails
    render :update do |page|
      page.replace_html 'preview_area', asset_link_with_preview(@asset)
    end
  end

  # xhr request
  def poll_preview
    large_thumb = @asset.thumbnails.find_by_name('large')
    if large_thumb.exists?
      render :update do |page|
        page.replace_html 'preview_area', asset_link_with_preview(@asset)
      end
    elsif large_thumb.remote_job.nil?
      large_thumb.generate
    elsif large_thumb.remote_job.status == 'finished'
      large_thumb.fetch_data_from_remote_job
         #suck_down_binary(remote_job.fetchy_url)
         self.private_filename = copy(remote_job.output_file)
      render :update do |page|
        page.replace_html 'preview_area', asset_link_with_preview(@asset)
      end
    elsif large_thumb.remote_job.status == 'failure'
      render :update do |page|
        page.replace_html 'preview_area', "FAILURE!!!!"
      end
    end
  end

  protected

  def fetch_data
    @asset = @page.data if @page
  end

  def setup_options
    @options.show_assets = false
    if action?(:show, :edit, :history)
      @options.show_tabs   = true
    end
  end

end
