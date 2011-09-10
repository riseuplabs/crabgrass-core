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

  #
  # xhr request
  #
  def poll_remote_asset
    large_thumb = @asset.thumbnail(:large)
    if large_thumb.failure
      if params[:retry]
        large_thumb.generate(:force => true)
        render :nothing => true # keep polling
      elsif !large_thumb.remote_job.nil?
        render :update do |page|
          # this is repeated from asset_page_helper == bad
          page.replace_html 'preview_area', 'remote job failed:   ' + link_to_remote('click here to view error', :url => page_xpath(@page, :action => 'view_remote_asset'))
        end
      else
        render :update do |page|
          page << stop_polling #'assetTimer.stop'
          page.replace_html 'preview_area', 'error'
          # TODO: replace 'error' with a link to get more info on the error.
        end
      end
    elsif large_thumb.exists?
      render :update do |page|
        page.replace_html 'preview_area', asset_link_with_preview(@asset)
      end
    elsif large_thumb.remote_job.nil?
      large_thumb.generate
      render :nothing => true # keep polling
    #elsif large_thumb.remote_job.status == 'finished'
    #  large_thumb.fetch_data_from_remote_job
    #     #suck_down_binary(remote_job.fetchy_url)
    #     self.private_filename = copy(remote_job.output_file)
    #  render :update do |page|
    #    page.replace_html 'preview_area', asset_link_with_preview(@asset)
    #  end
    elsif large_thumb.remote_job.status == 'failure'
      render :update do |page|
        page.replace_html 'preview_area', "remote FAILURE!!!!"
      end
    end
  end

  # xhr
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

end
