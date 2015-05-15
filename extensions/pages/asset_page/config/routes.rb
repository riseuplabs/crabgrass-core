Rails.application.routes.draw do
  scope path: 'pages' do
    resources :assets,
      only: [:show, :edit, :update],
      controller: :asset_page
    get 'assets/create(/:owner)', to: 'create_asset_page#new',
      as: :asset_page_creation
    post 'assets/create(/:owner)', to: 'create_asset_page#create',
      as: :asset_page_creation
  end

  scope path: 'pages/:page_id' do
    resources :versions, controller: :asset_page_versions,
      only: [:index, :create, :destroy]
  end
end
