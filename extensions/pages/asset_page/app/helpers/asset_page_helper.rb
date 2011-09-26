module AssetPageHelper

  #
  # displays a preview of the asset, with a link to the full thing.
  # if the preview does not yet exist, or has failed, then we show
  # appropriate controls for this.
  #
  def thumbnail_link_to_asset(asset, size)
    thumbnail = asset.thumbnail(size)
    if thumbnail.nil?
      show_generic_asset(asset)
    elsif thumbnail.failure?
      show_failed_thumbnail(thumbnail)
    elsif thumbnail.new? or thumbnail.processing?
      show_processing_thumbnail(thumbnail)
    elsif thumbnail.missing?
      show_missing_thumbnail(thumbnail)
    else
      show_large_thumbnail(asset)
    end
  end

  #def download_link
  #  image_tag('actions/download.png', :size => '32x32', :style => 'vertical-align: middle;') + link_to("Download", @asset.url)
  #end

  #def upload_link
  #  image_tag('actions/upload.png', :size => '32x32', :style => 'vertical-align: middle;') + link_to_function("Upload new version", "$('upload_new').toggle()") if current_user.may?(:edit, @page)
  #end

  def destroy_version_link(version)
    if may_destroy_asset_page_history? and version.version < @asset.version
      action = {
        :url => page_xpath(@page, :controller => :history, :action => 'destroy', :id => version.version),
        :confirm => I18n.t(:delete_version_confirm)
        #:before => "$($(this).up('td')).addClassName('busy')",
        #:failure => "$($(this).up('td')).removeClassName('busy')"
      }
      link_to_remote(:remove.t, action, :icon => 'tiny_trash')
    end
  end

  def preview_area_class(asset)
    'checkerboard' if asset.thumbnail(:large)
  end

  def display_logs(logs)
    haml do
      haml('ol.bullets') do
        logs.each do |l|
          haml(:li, h(l.text))
        end
      end
    end
  end

  private

  ##
  ## SHOW THE THUMBNAIL
  ## 

  def show_failed_thumbnail(thumbnail)
    if thumbnail.remote?
      if thumbnail.remote_job.nil?
        'failed to create remote job. ' + link_to_job_reset
      else
        'remote job failed. ' + link_to_job_details
      end
    else
      'thumbnail generation failed'
    end
  end

  def show_processing_thumbnail(thumbnail)
    if thumbnail.remote?
      javascript = start_polling
    else
      javascript = javascript_tag(remote_function(:url => page_xpath(@page, :action => 'show_thumbnail')))
    end
     preview_area(javascript)
  end

  def show_missing_thumbnail(thumbnail)
    if thumbnail.remote?
      if thumbnail.remote_job.nil?
        'missing remote job'
      else
        "remote job stalled. #{h thumbnail.inspect}" + link_to_job_details
      end
    else
      "missing thumbnail"
    end
  end

  def show_generic_asset(asset)
    link_to( image_tag(asset.big_icon), asset.url )
  end

  def show_large_thumbnail(asset)
    link_to_asset(asset, :large, :class => '')
  end

  def start_polling
    frequency = 4
    options = {:url => page_xpath(@page, :action => 'show_thumbnail')}
    code = "var assetTimer = new PeriodicalExecuter(function() {#{remote_function(options)}}, #{frequency})"
    javascript_tag(code)
  end

  def stop_polling
    'if (typeof assetTimer != "undefined") {assetTimer.stop();}'
  end

  def preview_area(javascript)
    width, height = [300,300]
    style = "height:#{height}px; width:#{width}px; background: white url(/images/spinner-big.gif) no-repeat 50% 50%;"
    content_tag(:div, javascript, :id => 'preview-loading', :style => style)
  end

  def link_to_job_details
    link_to_modal('click here to view details', :url => page_xpath(@page, :action => 'show_job'), :title => 'Remote Job')
  end

  def link_to_job_reset
    link_to_remote('click here to try again', :url => page_xpath(@page, :action => 'show_thumbnail', :retry => true))
  end

end

