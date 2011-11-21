module Common::Ui::AssetsHelper

  def asset_rows
    render :partial => 'common/assets/asset_as_row',
      :collection => (@assets || @page.assets)
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

