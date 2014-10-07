
define_page_type :RateManyPage, {
  controller: ['rate_many_page', 'rate_many_possibles'],
  model: 'Poll',
  icon: 'page_approval',
  class_group: 'vote',
  order: 10
}

Crabgrass.mod_routes do
  scope path: 'pages' do
    resources :rate_manys,
      only: [:show],
      controller: :rate_many_page do
        get :print, on: :member
      end
  end

  scope path: 'pages/:page_id' do
    resources :rate_many_possibles,
      only: [:create, :update, :destroy] do
      post :sort, on: :collection
    end
  end
end
