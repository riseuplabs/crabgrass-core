require 'crabgrass/page/engine'

module CrabgrassRankedVotePage
  class Engine < ::Rails::Engine
    include Crabgrass::Page::Engine

    register_page_type :RankedVotePage,
                       controller: %w[ranked_vote_page ranked_vote_possibles],
                       model: 'Poll',
                       icon: 'page_ranked',
                       class_group: 'vote',
                       order: 11
  end
end
