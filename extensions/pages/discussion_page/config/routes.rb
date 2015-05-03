Rails.application.routes.draw do
  scope path: 'pages' do
    resources :discussions,
      only: [:show],
      controller: :discussion_page do
        get :print, on: :member
      end
  end
end
