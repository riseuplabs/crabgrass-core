define_page_type :AssetPage, {
  controller: ['asset_page', 'asset_page_versions'],
  creation_controller: 'create_asset_page',
  model: 'Asset',
  form_sections: ['file'],
  icon: 'page_package',
  class_group: ['media', 'media:image', 'media:audio', 'media:document'],
  order: 10
}

Crabgrass.mod_routes do
  scope path: 'pages' do
    resources :assets,
      only: [:show, :new, :edit, :update],
      controller: :asset_page
  end

  scope path: 'pages/:page_id' do
    resources :versions, controller: :asset_page_versions,
      only: [:index, :create, :destroy]
  end
end
