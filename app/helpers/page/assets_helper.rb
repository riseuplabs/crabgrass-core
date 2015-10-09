module Page::AssetsHelper

  def popup_attachment_list(assets)
    content_tag :ul, id: 'assets_list', class: 'list-inline' do
      if assets.empty?
        content_tag :li, :none.t
      else
        render partial: '/common/assets/asset_as_li', collection: assets
      end
    end
  end

end