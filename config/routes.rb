#
# Some of these are not used for routes right now. But we still reserve
# them for later use.
# posts is currently used in routes from the moderation mod.
#
unless defined?(FORBIDDEN_NAMES)
  FORBIDDEN_NAMES = %w{
    account admin none assets avatars chat code debug do groups
    javascripts me networks page pages people pictures places posts
    issues session static stats stylesheets theme wikis
  }
end

#  See http://guides.rubyonrails.org/v3.1.0/routing.html

Crabgrass::Application.routes.draw do

  ##
  ## CRON JOBS
  ##

  # TODO: specify http verb
  match '/do/cron/run(/:id)', to: 'cron#run', format: false,
    constraints: {ip: /127.0.0.1/}

  ##
  ## STATIC FILES AND ASSETS
  ##

  resources :assets, only: [:show, :destroy]
  get '/assets/:id/versions/:version/*path',
    to: 'assets#show',
    as: 'asset_version'
  get '/assets/:id(/*path)', to: 'assets#show', as: 'asset'

  scope format: false do
    get 'avatars/:id/:size.jpg', to: 'avatars#show', as: 'avatar', constraints: {size: /#{Avatar::SIZES.keys.join('|')}/}
    get 'theme/:name/*file.css', to: 'theme#show'
  end

  get 'pictures/:id1/:id2(/:geometry)',
    to: 'pictures#show',
    as: 'pictures'

  ##
  ## ME
  ##

  namespace 'me' do
    resources :notices, only: [:index, :show, :destroy]
    get '', to: 'notices#index', as: 'home'
    # resource  :page, only: [:new, :create]
    resources :recent_pages, only: [:index]
    get 'pages(/*path)', to: 'pages#index', as: 'pages'
    post 'pages(/*path)', to: 'pages#index', as: 'pages'
    resources :activities, only: [:index, :show, :create]
    resources :discussions, path: 'messages', only: :index do
      resources :posts, except: [:show, :new]
    end
    resource  :settings, only: [:show, :update]
    resource  :destroy, only: [:show, :update]
    resource  :password, only: [:edit, :update]
    resources :permissions, only: [:index, :update]
    resource  :profile, controller: 'profile', only: [:edit, :update]
    resources :requests, only: [:index, :update, :destroy, :show]
    # resources :events, only: [:index]
    resource :avatar, only: [:create, :edit, :update]
    resources :tasks, only: [:index]
  end

  ##
  ## EMAIL
  ##

  # UPGRADE: this is pre rails 3 syntax. If you want to bring these
  # routes back please upgrade them
  #  match '/invites/:action/*path', controller: 'requests', action: /accept/
  #  match '/code/:id', to: 'codes#jump'

  ##
  ## ACCOUNT
  ##

  resource :account, only: [:new, :create]
  match 'account/reset_password(/:token)',
    as: 'reset_password',
    to: 'accounts#reset_password',
    via: [:get, :post]


  post 'session/language', as: 'language', to: 'session#language'
  post 'session/login', as: 'login',  to: 'session#login'
  post 'session/logout', as: 'logout', to: 'session#logout'
  # ajax login form
  get   'session/login_form', as: 'login_form', to: 'session#login_form',
    constraints: lambda{|request| request.xhr?}


  ##
  ## ENTITIES
  ##

  # autocomplete queries, restricted to ajax
  resources :entities, only: [:index],
    constraints: lambda{|request| request.xhr?}

  ##
  ## PEOPLE
  ##

  get 'people/directory(/*path)',
    as: 'people_directory',
    to: 'people/directory#index'

  post 'people/directory(/*path)',
    as: 'people_directory',
    to: 'people/directory#index'

  resources :people, module: 'people', controller: 'home', only: :show do
    resource  :home, only: :show, controller: 'home'
    get 'pages(/*path)', as: 'pages', to: 'pages#index'
    post 'pages(/*path)', as: 'pages', to: 'pages#index'
    # resources :messages
    # resources :activities
    resource :friend_request, only: [:new, :create, :destroy]
  end

  ##
  ## GROUP
  ##

  get 'networks/directory(/*path)', as: 'networks_directory', to: 'groups/directory#index'
  get 'groups/directory(/*path)', as: 'groups_directory', to: 'groups/directory#index'

  resources :groups, module: 'groups', only: [:new, :create, :destroy] do
    # content related
    resource  :home, only: [:show], controller: 'home'
    get 'pages(/*path)', as: 'pages', to: 'pages#index'
    post 'pages(/*path)', as: 'pages', to: 'pages#index'
    resource  :avatar, only: [:create, :edit, :update]
    resources :wikis, only: [:create, :index]

    # membership related
    resources :memberships, only: [:index, :create, :destroy]
    resources :my_memberships, only: [:create, :destroy]
    resources :membership_requests , except: [:new, :edit]
    resource  :invite, only: [:new, :create]

    # settings related
    resource  :settings, only: [:show, :update]
    resources :requests , except: [:new, :edit]
    resources :permissions, only: [:index, :update]
    resource  :profile, only: [:edit, :update]
    resource  :structure, only: [:show, :new, :create, :update]
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
    to: 'pages/create#new'
  post '/pages/create(/:owner(/:type))',
    as: 'page_creation',
    to: 'pages/create#create'

  # base page
  resources :pages, module: 'pages', controller: 'base', only: [] do |pages|
    resources :participations, only: [:index, :update, :create]
    #resources :changes
    resources :assets, only: [:index, :update, :create]
    resources :tags, only: [:index, :create, :destroy, :show]
    resources :posts, except: [:new]

    # page sidebar/popup controllers:
    resource :sidebar,    only: [:show]
    resource :share,      only: [:show, :update],
      constraints: lambda{|request| request.xhr?}
    resource :details,    only: [:show]
    resource :history,    only: [:show], controller: 'history'
    resource :attributes, only: [:update]
    resource :title,      only: [:edit, :update], controller: 'title'
    resource :trash,      only: [:edit, :update], controller: 'trash'
  end

  ##
  ## WIKI
  ##

  resources :wikis, module: 'wikis', only: [:show, :edit, :update] do
    member do
      get 'print'
    end
    resource :lock, only: [:destroy, :update]
    resources :assets, only: [:new, :create]
    resources :versions, only: [:index, :show] do
      member do
        post 'revert'
      end
    end
    resources :diffs, only: [:show]
  end

  ##
  ## OTHER ROUTES
  ##

  root to: 'root#index'
  get '/do/static/greencloth', to: 'static#greencloth'

  ##
  ## SPECIAL PATH ROUTES for PAGES and ENTITIES
  ##

  resources :contexts, path: "", only: :show do
    resources :pages, path: "",
      controller: :context_pages,
      except: [:index, :new, :create] do
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
  #scope path: ':context_id/:page_id/:controller' do
  #  resources :context_page_items, path: '' do
  #    collection do
  #      post :sort
  #    end
  #  end
  #end

end

