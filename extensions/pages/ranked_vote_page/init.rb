define_page_type :RankedVotePage, {
  controller: ['ranked_vote_page', 'ranked_vote_possibles'],
  model: 'Poll',
  icon: 'page_ranked',
  class_group: 'vote',
  order: 11
}

