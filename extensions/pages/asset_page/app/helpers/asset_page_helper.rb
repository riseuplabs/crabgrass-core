module AssetPageHelper

  def asset_link_with_preview(asset)
    thumbnail = asset.thumbnail(:large)
    if thumbnail.nil?
      link_to( image_tag(asset.big_icon), asset.url )
    elsif !thumbnail.exists?
      load_preview_tag + javascript_tag(create_preview_javascript)
    else
      link_to_asset(asset, :large, class: '')
    end
  end

  def load_preview_tag
      #if false and thumbnail.width
      #  width = thumbnail.width
      #  height = thumbnail.height
      #else
      #  width, height = thumbnail.thumbdef.size.split /[x><]/
      #end
      width, height = [300,300]
      style = "height:#{height}px; width:#{width}px;"
      style += "background: white url(/images/spinner-big.gif) no-repeat 50% 50%;"
      content_tag(:div, '', id: 'preview-loading', style: style)
  end

  def create_preview_javascript
    remote_function method: :post, url: page_items_url(controller: :preview)
  end

  #def download_link
  #  image_tag('actions/download.png', :size => '32x32', :style => 'vertical-align: middle;') + link_to("Download", @asset.url)
  #end

  #def upload_link
  #  image_tag('actions/upload.png', :size => '32x32', :style => 'vertical-align: middle;') + link_to_function("Upload new version", "$('upload_new').toggle()") if current_user.may?(:edit, @page)
  #end

  def destroy_version_link(version)
    if may_edit_page? and version.version < @asset.version
      action = {
        url: page_item_url(version.version),
        method: :delete,
        confirm: I18n.t(:delete_version_confirm)
        #:before => "$($(this).up('td')).addClassName('busy')",
        #:failure => "$($(this).up('td')).removeClassName('busy')"
      }
      link_to_remote(:remove.t, action, icon: 'tiny_trash')
    end
  end

  def preview_area_class(asset)
    'checkerboard' if asset.thumbnail(:large)
  end
end

