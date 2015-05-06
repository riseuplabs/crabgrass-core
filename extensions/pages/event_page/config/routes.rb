Rails.application.routes.draw do
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

