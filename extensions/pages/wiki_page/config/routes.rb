Rails.application.routes.draw do
  scope path: 'pages' do
    resources :wikis, controller: :wiki_page, only: :show do
      member do
        get :print
      end
    end
  end
end

