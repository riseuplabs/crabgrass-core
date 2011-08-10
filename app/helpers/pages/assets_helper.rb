module Pages::AssetsHelper

  # TODO: fix styles so that we don't have to force no padding here
  def asset_row(asset)
    content_tag(:td,
      update_cover_asset_checkbox(asset)
    ) +
    content_tag(:td,
      link_to_asset(asset, :small), :style => 'width: 1%'
    ) +
    content_tag(:td,
      link_to( h(asset.filename), asset.url) 
    ) +
    content_tag(:td,
      remove_asset_link(asset)
    )
  end

  def asset_rows
    @page.assets.collect do |asset|
      content_tag(:tr, asset_row(asset), :id => dom_id(asset), :class => cycle('even','odd'))
    end.join("\n")
  end

  def remove_asset_link(asset)
    link = link_to_remote(
       "remove",
       { :url => page_asset_path(@page, asset.id),
          :method => :delete,
          :complete => hide(dom_id(asset)) },
#      :html => {:style => 'display:inline; padding:0;'},
      { :confirm => :destroy_confirmation.t(:thing => 'attachment'),
#      :loading  => show_spinner('popup'),
        :icon => 'minus'}
    )
  end

  def update_cover_asset_checkbox(asset)
    checked = asset ? @page.cover == asset : false
    opts = {}
    unless checked
      opts[:onclick] = remote_function(
        :url => {:controller => 'base_page/assets', :action => 'update', :id => asset.id, :page_id => @page.id},
        :loading  => show_spinner('popup'),
        :complete => hide_spinner('popup'))
    end

    radio_button_tag "cover_id", asset.id, checked, opts
  end

  def remove_cover_asset_checkbox
    opts = {:onclick => remote_function(
      :url => {:controller => 'base_page/assets', :action => 'update', :page_id => @page.id},
      :loading  => show_spinner('popup'),
      :complete => hide_spinner('popup'))}

    radio_button_tag "cover_id", 'none', @page.cover.blank?, opts
  end
end

