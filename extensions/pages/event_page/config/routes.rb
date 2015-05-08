Rails.application.routes.draw do
  scope path: 'pages' do
    resources :events,
      only: [:show, :edit, :update],
      controller: :event_page
    match 'events/create(/:owner)',
      to: 'create_event_page#new',
      as: :event_page_creation,
      via: [:get, :post]
  end
end

