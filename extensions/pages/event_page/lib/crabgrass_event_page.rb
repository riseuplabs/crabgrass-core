require 'crabgrass/page/engine'

module CrabgrassEventPage
  class Engine < ::Rails::Engine
    include Crabgrass::Page::Engine

    register_page_type :EventPage,
                       controller: 'event_page',
                       creation_controller: 'create_event_page',
                       model: 'Event',
                       form_sections: ['event'],
                       icon: 'page_event',
                       class_group: ['event'],
                       order: 10
  end
end
