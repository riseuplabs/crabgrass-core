module AssetPageHelper

  def asset_link_with_preview(asset)
    thumbnail = asset.thumbnail(:large)
    if thumbnail.nil?
      show_generic_asset(asset)
    elsif thumbnail.failure?
      show_failed_thumbnail(thumbnail)
    elsif !thumbnail.exists?
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

  private

  ##
  ## SHOW THE THUMBNAIL
  ## 

  def show_failed_thumbnail(thumbnail)
    if thumbnail.remote_job.nil?
      'failed in the past:   ' + link_to_remote('click here to try again', :url => page_xpath(@page, :action => 'poll_remote_asset', :retry => true))
    else
      'remote job failed:   ' + link_to_modal('click here to view error', :url => page_xpath(@page, :action => 'view_remote_asset'))
    end
  end

  def show_missing_thumbnail(thumbnail)
    if thumbnail.remote?
      # poll until we get a valid thumbnail, or a failure.
      javascript = start_polling
    else
      # do a blocking call to show the thumbnail.
      javascript = javascript_tag(remote_function(:url => page_xpath(@page, :action => 'generate_preview')))
    end

    # no thumbnail yet, so show a spinner.
    width, height = [300,300]
    style = "height:#{height}px; width:#{width}px;"
    style += "background: white url(/images/spinner-big.gif) no-repeat 50% 50%;"
    content_tag(:div, javascript, :id=>'preview-loading', :style => style)
  end

  def show_generic_asset(asset)
    link_to( image_tag(asset.big_icon), asset.url )
  end

  def show_large_thumbnail(asset)
    link_to_asset(asset, :large, :class => '')
  end

  def start_polling
    frequency = 4
    options = {:url => page_xpath(@page, :action => 'poll_remote_asset')}
    code = "var assetTimer = new PeriodicalExecuter(function() {#{remote_function(options)}}, #{frequency})"
    javascript_tag(code)
  end

  def stop_polling
    'if (typeof assetTimer != "undefined") {assetTimer.stop();}'
  end

end

