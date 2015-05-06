require 'crabgrass/page/engine'

module CrabgrassDiscussionPage
  class Engine < ::Rails::Engine
    include Crabgrass::Page::Engine

    register_page_type 'DiscussionPage',
      controller: 'discussion_page',
      icon: 'page_discussion',
      class_group: ['text', 'discussion'],
      order: 2

  end
end
