#
# Some of these are not used for routes right now. But we still reserve
# them for later use.
# posts is currently used in routes from the moderation mod.
#
unless defined?(FORBIDDEN_NAMES)
  FORBIDDEN_NAMES = %w[
    account admin none assets avatars chat code debug do groups
    javascripts me networks page pages people pictures places posts
    issues session static stats stylesheets theme wikis
  ].freeze
end

#  See http://guides.rubyonrails.org/v3.1.0/routing.html

Crabgrass::Application.routes.draw do
  ##
  ## CRON JOBS
  ##

  post '/do/cron/run(/:id)', to: 'cron#run', format: false,
                             constraints: { ip: /127.0.0.1/ }

  ##
  ## CSP Reports
  ##

  resource :csp_report, only: [:create]

  ##
  ## STATIC FILES AND ASSETS
  ##

  # same as the asset_path without
  resources :assets, only: [:destroy], as: 'destroy_asset'
  get '/assets/:id/versions/:version/*path',
      to: 'assets#show',
      as: 'asset_version'
  get '/assets/:id(/*path)', to: 'assets#show', as: 'asset'

  scope format: false do
    get 'avatars/:id/:size.jpg',
      to: 'avatars#show',
      as: 'avatar',
      constraints: { size: /#{Avatar::SIZES.keys.join('|')}/ }
    get 'theme/:name/*file.css', to: 'theme#show'
  end

  get 'pictures/:id1/:id2(/:geometry)',
      to: 'pictures#show',
      as: 'pictures'

  ##
  ## ME
  ##

  namespace 'me' do
    delete 'notices/destroy_all',
      to: 'notices#destroy_all',
      as: 'notices_destroy_all'
    resources :notices, only: %i[index destroy]
    get '', to: 'home#index', as: 'home'
    # resource  :page, only: [:new, :create]
    resources :recent_pages, only: [:index]
    match 'pages(/*path)', to: 'pages#index', as: 'pages', via: %i[get post]
    resources :discussions, path: 'messages', only: :index do
      resources :posts, except: [:new]
    end
    resource  :settings, only: %i[show update]
    resource  :destroy, only: %i[show update]
    resource  :password, only: %i[edit update]
    resources :permissions, only: %i[index update]
    resource  :profile, controller: 'profile', only: %i[edit update]
    resources :requests, only: %i[index update destroy show]
    resource :avatar, only: %i[create edit update destroy]
    resources :tasks, only: [:index]
  end

  ##
  ## EMAIL
  ##

  # UPGRADE: this is pre rails 3 syntax. If you want to bring these
  # routes back please upgrade them
  #  match '/invites/:action/*path', controller: 'requests', action: /accept/
  get '/code/:id', to: 'codes#jump'

  ##
  ## ACCOUNT
  ##

  resource :account, only: %i[new create]
  match 'account/reset_password(/:token)',
        as: 'reset_password',
        to: 'accounts#reset_password',
        via: %i[get post]

  post 'session/language', as: 'language', to: 'session#language'
  post 'session/login', as: 'login', to: 'session#login'
  post 'session/logout', as: 'logout', to: 'session#logout'
  # ajax login form
  get 'session/login_form', as: 'login_form', to: 'session#login_form',
                            constraints: ->(request) { request.xhr? }

  ##
  ## ENTITIES
  ##

  # autocomplete queries, restricted to ajax
  resources :entities, only: [:index],
                       constraints: ->(request) { request.xhr? }

  ##
  ## PEOPLE
  ##

  match 'people/directory(/*path)',
        as: 'people_directory',
        to: 'person/directory#index',
        via: %i[get post]

  resources :people, module: 'person', controller: 'home', only: :show do
    resource :home, only: :show, controller: 'home'
    match 'pages(/*path)', as: 'pages', to: 'pages#index', via: %i[get post]
    # resources :messages
    resource :friend_request, only: %i[new create destroy]
  end

  ##
  ## GROUP
  ##

  get 'networks/directory(/*path)',
    as: 'networks_directory',
    to: 'group/directory#index'
  get 'groups/directory(/*path)',
    as: 'groups_directory',
    to: 'group/directory#index'

  resources :groups, module: 'group', only: %i[new create destroy] do
    # content related
    resource :home, only: [:show], controller: 'home'
    match 'pages(/*path)', as: 'pages', to: 'pages#index', via: %i[get post]
    resource  :avatar, only: %i[create edit update]
    resources :wikis, only: %i[create index]

    # membership related
    resources :memberships, only: %i[index create destroy]
    resources :my_memberships, only: %i[create destroy]
    resources :membership_requests, except: %i[new edit]
    resource  :invite, only: %i[new create]

    # settings related
    resource  :settings, only: %i[show update]
    resources :requests, except: %i[new edit]
    resources :permissions, only: %i[index update]
    resource  :profile, only: %i[edit update]
    resource  :structure, only: %i[show new create update]
  end

  ##
  ## DEBUGGING
  ##

  if Rails.env.development?
    post 'debug/become', as: 'debug_become', to: 'debug#become'
    get 'debug/break', as: 'debug_break', to: 'debug#break'
  end
  # There's no bugreport controller right now it seems
  # match 'debug/report/submit', as: 'debug_report', to: 'bugreport#submit'

  ##
  ## NORMAL PAGE ROUTES
  ##

  # default page creator
  get '/pages/create(/:owner(/:type))',
      as: 'page_creation',
      to: 'page/create#new'
  post '/pages/create(/:owner(/:type))',
       to: 'page/create#create'

  # base page
  resources :pages, module: 'page', controller: 'base', only: [] do |_pages|
    resources :participations, only: %i[index update create]
    # resources :changes
    resources :assets, only: %i[index update create]
    resources :tags, only: %i[index create destroy show], :constraints => { :id => /.*/ }
    resources :posts, except: [:new]

    # page sidebar/popup controllers:
    resource :sidebar,    only: [:show]
    resource :share,      only: %i[show update],
                          constraints: ->(request) { request.xhr? }
    resource :details,    only: [:show]
    resource :history,    only: [:show], controller: 'history'
    resource :attributes, only: [:update]
    resource :title,      only: %i[edit update], controller: 'title'
    resource :trash,      only: %i[edit update destroy], controller: 'trash'
  end

  resources :posts, only: [] do |_posts|
    resource :star, only: %i[create destroy]
  end

  ##
  ## WIKI
  ##

  resources :wikis, module: 'wiki', only: %i[show edit update] do
    member do
      get 'print'
    end
    resource :lock, only: %i[destroy update]
    resources :assets, only: %i[new create]
    resources :versions, only: %i[index show] do
      member do
        post 'revert'
      end
    end
  end

  ##
  ## OTHER ROUTES
  ##

  root to: 'root#index'
  get '/do/static/greencloth', to: 'static#greencloth'

  ##
  ## SPECIAL PATH ROUTES for PAGES and ENTITIES
  ##

  resources :contexts, path: '', only: :show, constraints: { format: :html } do
    resources :pages, path: '',
                      controller: :context_pages,
                      only: %i[show edit] do
      member do
        get 'print'
      end
    end
  end

  #
  # I'm not sure we will ever want this...
  # deeply nested routes are considered a bad practice and even though
  # the url does not grow as much this basically boils down to using
  # a deeply nested approach.
  #
  # Instead we probably want
  # /pages/:page_id/...
  #
  # scope path: ':context_id/:page_id/:controller' do
  #  resources :context_page_items, path: '' do
  #    collection do
  #      post :sort
  #    end
  #  end
  # end
end
