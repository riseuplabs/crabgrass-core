define_page_type :EventPage, {
  controller: 'event_page',
  creation_controller: 'create_event_page',
  model: 'Event',
  form_sections: ['event'],
  icon: 'page_event',
  class_group: ['event'],
  order: 10
}

Crabgrass.mod_routes do
  scope path: 'pages' do
    resources :events,
      only: [:show, :edit, :update],
      controller: :event_page
    get 'events/create(/:owner)', to: 'create_event_page#new',
      as: :event_page_creation
    post 'events/create(/:owner)', to: 'create_event_page#create',
      as: :event_page_creation
  end
end

