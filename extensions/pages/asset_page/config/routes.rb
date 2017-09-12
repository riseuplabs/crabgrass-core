Rails.application.routes.draw do
  scope path: 'pages' do
    resources :assets,
              as: :asset_pages,
              only: %i[show edit update],
              controller: :asset_page
    get 'assets/create(/:owner)',
        to: 'create_asset_page#new',
        as: :asset_page_creation
    post 'assets/create(/:owner)',
         to: 'create_asset_page#create'
  end

  scope path: 'pages/:page_id' do
    resources :versions, controller: :asset_page_versions,
                         only: %i[index create destroy]
  end
end
