module Common::Ui::AssetsHelper
  def remove_asset_button(asset, options = {}, html_options = {})
    options.reverse_merge!(url: asset_path(asset.id),
                           method: :delete,
                           complete: hide(dom_id(asset)))
    html_options[:icon] = 'trash'
    html_options[:class] = 'small_icon_button trash_16'
    html_options.reverse_merge!(confirm: :destroy_confirmation.t(thing: 'attachment'))
    link_to_with_confirm('', options, html_options)
  end
end
