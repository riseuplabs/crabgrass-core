Rails.application.routes.draw do
  scope path: 'pages' do
    resources :events,
              only: %i[show edit update],
              controller: :event_page
    match 'events/create(/:owner)',
          to: 'create_event_page#new',
          as: :event_page_creation,
          via: %i[get post]
  end
end
