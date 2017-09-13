Rails.application.routes.draw do
  scope path: 'pages' do
    resources :ranked_votes,
              only: %i[show edit],
              controller: :ranked_vote_page do
      get :print, on: :member
    end
  end

  scope path: 'pages/:page_id' do
    resources :ranked_vote_possibles,
              only: %i[create update edit destroy] do
      post :sort, on: :collection
    end
  end
end
