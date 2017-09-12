require 'crabgrass/page/engine'

module CrabgrassAssetPage
  class Engine < ::Rails::Engine
    include Crabgrass::Page::Engine

    register_page_type :AssetPage,
                       controller: %w[asset_page asset_page_versions],
                       creation_controller: 'create_asset_page',
                       model: 'Asset',
                       form_sections: ['file'],
                       icon: 'page_package',
                       class_group: ['media', 'media:image', 'media:audio', 'media:document'],
                       order: 10
  end
end
