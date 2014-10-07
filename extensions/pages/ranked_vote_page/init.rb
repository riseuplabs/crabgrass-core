define_page_type :RankedVotePage, {
  controller: ['ranked_vote_page', 'ranked_vote_possibles'],
  model: 'Poll',
  icon: 'page_ranked',
  class_group: 'vote',
  order: 11
}


Crabgrass.mod_routes do
  scope path: 'pages' do
    resources :ranked_votes,
      only: [:show, :edit, :update],
      controller: :ranked_vote_page
  end

  scope path: 'pages/:page_id' do
    resources :ranked_vote_possibles,
      only: [:create, :update, :edit, :destroy] do
      post :sort, on: :collection
    end
  end

end

