Rails.application.routes.draw do
  scope path: 'pages' do
    resources :surveys,
      only: [:show],
      controller: :survey_page do
        get :print, on: :member
      end
  end

  scope path: 'pages/:page_id' do
    resources :responses, only: [:show, :index],
      controller: :survey_page_response
  end
end
