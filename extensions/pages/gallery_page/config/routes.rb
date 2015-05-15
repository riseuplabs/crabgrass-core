Rails.application.routes.draw do
  scope path: 'pages' do
    resources :galleries,
      only: [:show, :edit],
      controller: :gallery
  end

  scope path: 'pages/:page_id'  do
    resources :images, controller: :gallery_image,
      only: [:show] do
      post :sort, on: :collection
    end
  end
end
