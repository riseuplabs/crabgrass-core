define_page_type :AssetPage, {
  :controller => ['asset_page', 'asset_page_history'],
  :creation_controller => 'create_asset_page',
  :model => 'Asset',
  :form_sections => ['file'],
  :icon => 'page_package',
  :class_group => ['media', 'media:image', 'media:audio', 'media:document'],
  :order => 10
}

