class AssetPageController < Pages::BaseController
  permissions   'asset_page'

  def show
    if @asset.nil?
      redirect_to page_url(@page, :action => 'new')
      return
    end

    #thumb = @asset.thumbnail(:large)
    #if thumb and thumb.remote? and thumb.new?
    #  thumb.generate(:host => host)
    #end
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
  # Show the large thumbnail preview of this asset. If it doesn't exist yet, 
  # we fire off the request to have it generated, either locally or remotely.
  # xhr request only.
  #
  def show_thumbnail
    thumb = @asset.thumbnail(:large)

    if thumb.new? or params[:retry]
      thumb.generate(:force => true, :host => host)
    end

    if thumb.processing?
      keep_polling
    else
      update_preview(@asset, :stop_polling => true)
    end
  end

  #
  # Show details about the remote job. Shown in a popup if there were any failures.
  #
  def show_job
    @thumbnail = @asset.thumbnail(:large)
  end

  #
  # post action to requeue the job.
  #
  def requeue_job
    job = @asset.thumbnail(:large).remote_job
    unless job.state == 'processing'
      job.run
    end
    redirect_to page_url(@page)
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
      page.replace_html 'preview_area', thumbnail_link_to_asset(asset, :large)
    end
  end

  # a dummy response to keep the timer still polling
  def keep_polling
    render :nothing => true
  end

  def host
    request.protocol + request.host_with_port
  end

end
