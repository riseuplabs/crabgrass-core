Rails.application.routes.draw do
  scope path: 'pages' do
    resources :rate_manys,
              only: [:show],
              controller: :rate_many_page do
      get :print, on: :member
    end
  end

  scope path: 'pages/:page_id' do
    resources :rate_many_possibles,
              only: %i[create update destroy] do
      post :sort, on: :collection
    end
  end
end
