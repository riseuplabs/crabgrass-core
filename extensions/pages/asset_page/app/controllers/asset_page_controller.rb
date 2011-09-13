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

  #
  # xhr request
  #
  def generate_preview
    @asset.generate_thumbnails
    update_preview(@asset)
  end

  #
  # xhr request
  #
  def poll_remote_asset
    large_thumb = @asset.thumbnail(:large)
    if large_thumb.processing?
      keep_polling
    elsif params[:retry]
      large_thumb.generate(:force => true)
      keep_polling
    els
    else
      update_preview(@asset, :stop_polling => true)
    end
  end

  #
  # xhr
  #
  def view_remote_asset
    thumb = @asset.thumbnail(:large)
    return unless thumb
    ret = 'no remote job found!'
    if thumb.remote_job
      ret = thumb.remote_job.inspect
    end
    render :text => ret
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

  #
  # creates an rjs response to update the preview area
  #
  def update_preview(asset, options={})
    render :update do |page|
      if options[:stop_polling]
        page << stop_polling
      end
      page.replace_html 'preview_area', asset_link_with_preview(asset)
    end
  end

  # a dummy response to keep the timer still polling
  def keep_polling
    render :nothing => true
  end

end
