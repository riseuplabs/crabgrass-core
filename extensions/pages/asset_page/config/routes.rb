Rails.application.routes.draw do
  scope path: 'pages' do
    resources :assets,
      only: [:show, :edit, :update],
      controller: :asset_page
    match 'assets/create(/:owner)',
      to: 'create_asset_page#new',
      as: :asset_page_creation,
      via: [:get, :post]
  end

  scope path: 'pages/:page_id' do
    resources :versions, controller: :asset_page_versions,
      only: [:index, :create, :destroy]
  end
end
