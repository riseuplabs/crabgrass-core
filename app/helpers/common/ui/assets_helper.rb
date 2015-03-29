module Common::Ui::AssetsHelper

# this is currently unused - assets come in lists now.
  def asset_rows
    render partial: 'common/assets/asset_as_row',
      collection: (@assets || @page.assets)
  end

  def remove_asset_button(asset)
    remove_asset_link(asset, {class: 'btn btn-danger btn-mini'})
  end

  def remove_asset_link(asset, options = {}, html_options = {})
    icon ||= 'trash'
    options.reverse_merge!({
      url: asset_path(asset.id),
      method: :delete,
      complete: hide(dom_id(asset))
    })
    html_options.reverse_merge!({
      confirm: :destroy_confirmation.t(thing: 'attachment')
    })
    link_to_remote_icon(icon, options, html_options)
  end

  def update_cover_asset_checkbox(asset)
    checked = asset ? @page.cover == asset : false
    opts = {}
    unless checked
      opts[:onclick] = remote_function(
        url: {controller: 'base_page/assets', action: 'update', id: asset.id, page_id: @page.id},
        loading: show_spinner('popup'),
        complete: hide_spinner('popup'))
    end

    radio_button_tag "cover_id", asset.id, checked, opts
  end

  def remove_cover_asset_checkbox
    opts = {onclick: remote_function(
      url: {controller: 'base_page/assets', action: 'update', page_id: @page.id},
      loading: show_spinner('popup'),
      complete: hide_spinner('popup'))}

    radio_button_tag "cover_id", 'none', @page.cover.blank?, opts
  end
end

