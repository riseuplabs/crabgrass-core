Rails.application.routes.draw do
  scope path: 'pages' do
    resources :wikis, controller: :wiki_page, only: :show do
      # TODO: bring back print view
      #        get :print, on: :member
    end
  end
end

