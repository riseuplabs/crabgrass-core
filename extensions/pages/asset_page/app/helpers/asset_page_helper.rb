module AssetPageHelper
  def asset_link_with_preview(asset)
    thumbnail = asset.thumbnail(:large)
    if thumbnail.nil?
      link_to(icon_for(asset), asset.url)
    elsif !thumbnail.exists?
      load_preview_tag + javascript_tag(create_preview_javascript)
    else
      link_to_asset(asset, :large, class: '')
    end
  end

  def load_preview_tag
    width = 300
    height = 300
    style = "height:#{height}px; width:#{width}px;"
    style += 'background: white url(/images/spinner-big.gif) no-repeat 50% 50%;'
    content_tag(:div, '', id: 'preview-loading', style: style)
  end

  def create_preview_javascript
    remote_function method: :post, url: versions_url(page_id: @page)
  end

  def destroy_version_link(version)
    if may_edit_page? and version.version < @asset.version
      options = {
        url: version_url(version.version, page_id: @page),
        method: :delete,
        remote: true,
        confirm: I18n.t(:delete_version_confirm) # FIXME: should be removed, needed for now as a flag for link_to to recognize remote call
      }
      html_options = { confirm: I18n.t(:delete_version_confirm), icon: 'tiny_trash' }
      link_to(:remove.t, options, html_options)
    end
  end

  def preview_area_class(asset)
    'checkerboard' if asset.thumbnail(:large)
  end
end
