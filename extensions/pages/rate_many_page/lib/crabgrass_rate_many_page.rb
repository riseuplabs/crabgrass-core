require 'crabgrass/page/engine'

module CrabgrassRateManyPage
  class Engine < ::Rails::Engine
    include Crabgrass::Page::Engine

    register_page_type :RateManyPage,
      controller: ['rate_many_page', 'rate_many_possibles'],
      model: 'Poll',
      icon: 'page_approval',
      class_group: 'vote',
      order: 10

  end
end

