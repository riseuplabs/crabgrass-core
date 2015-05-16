require 'crabgrass/page/engine'

module CrabgrassGalleryPage
  class Engine < ::Rails::Engine
    include Crabgrass::Page::Engine

    register_page_type :Gallery,
      controller: ['gallery', 'gallery_image'],
      icon: 'page_gallery',
      class_group: ['media', 'media:image', 'collection'],
      order: 30

    config.to_prepare do
      Asset.send :include, AssetExtension::Gallery
    end
  end
end

