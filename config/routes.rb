unless defined?(FORBIDDEN_NAMES)
  FORBIDDEN_NAMES = %w{
    account admin anonymous assets avatars chat code debug do groups
    javascripts me networks page pages people pictures places issues
    session static stats stylesheets theme wikis
  }
end

#
# useful options:
#
#   for normal routes
#
#     :conditions => {:method => :post}
#
#   for resources
#
#     :only => [:new, :show]
#     :member => {:edit => :any, :update => :get}
#

Crabgrass::Application.routes.draw do |map|

  ##
  ## CRON JOBS
  ##

  map.connect '/do/cron/run/:id', :controller => 'cron', :action => 'run'

  ##
  ## STATIC FILES AND ASSETS
  ##

  map.resources :assets, :only => [:show, :destroy]
  map.with_options(:controller => 'assets') do |assets|
    assets.asset_version '/assets/:id/versions/:version/*path', :action => 'show'
    assets.asset '/assets/:id(/*path)', :action => 'show'
  end

  map.avatar 'avatars/:id/:size.jpg', :controller => 'avatars', :action => 'show'
  map.connect 'theme/:name/*file.css', :controller => 'theme', :action => 'show'
  map.pictures 'pictures/:id1/:id2/:geometry.:format', :controller => 'pictures', :action => 'show'

  ##
  ## ME
  ##

  map.with_options(:namespace => 'me/', :path_prefix => 'me', :name_prefix => 'me_') do |me|
    me.resources :notices
    me.home      '', :controller => 'notices', :action => 'index'
    me.resource  :page, :only => [:new, :create]
    me.resources :recent_pages, :only => [:index]
    me.pages     'pages(/*path)', :controller => 'pages'
    me.resources :activities
    me.resources(:discussions, :as => 'messages') do |discussion|
      discussion.resources :posts
    end
    me.resource  :settings, :only => [:show, :update]
    me.resource  :destroy, :only => [:show, :update]
    me.resource  :password, :only => [:edit, :update]
    me.resources :permissions
    me.resource  :profile, :controller => 'profile', :only => [:edit, :update]
    me.resources :requests, :only => [:index, :update, :destroy, :show]
    me.resources :events
    me.resources :avatars
  end

  ##
  ## EMAIL
  ##

#  map.connect '/invites/:action/*path', :controller => 'requests', :action => /accept/
#  map.connect '/code/:id', :controller => 'codes', :action => 'jump'

  ##
  ## ACCOUNT
  ##

  map.with_options(:controller => 'account') do |account|
    account.reset_password 'account/reset_password/:token', :action => 'reset_password', :token => nil
    account.verify_account 'account/verify_email/:token',   :action => 'verify_email'
    account.new_account    'account/new', :action => 'new'
    account.account        'account/:action/:id'
  end

  map.with_options(:controller => 'session') do |session|
    session.language 'session/language', :action => 'language'
    session.login    'session/login',  :action => 'login'
    session.logout   'session/logout', :action => 'logout'
    session.session  'session/:action/:id'
  end

  ##
  ## ENTITIES
  ##

  map.resources :entities, :only => [:index]

  ##
  ## PEOPLE
  ##

  map.people_directory 'people/directory(/*path)', :controller => 'people/directory'

  map.resources :people, :namespace => 'people/' do |people|
    people.resource  :home, :only => [:show], :controller => 'home'
    people.pages     'pages(/*path)', :controller => 'pages'
    people.resources :messages
    people.resources :activities
    people.resource :friend_request, :only => [:new, :create, :destroy]
  end

  ##
  ## GROUP
  ##

  map.networks_directory 'networks/directory(/*path)', :controller => 'groups/directory'
  map.groups_directory 'groups/directory(/*path)', :controller => 'groups/directory'

  map.resources :groups, :namespace => 'groups/', :only => [:new, :create, :destroy] do |groups|
    # content related
    groups.resource  :home, :only => [:show], :controller => 'home'
    groups.pages     'pages(/*path)', :controller => 'pages'
    groups.resources :avatars
    groups.resources :wikis, :only => [:create, :index] #:except => [:index, :destroy, :update, ]

    # membership related
    groups.resources :memberships, :only => [:index, :create, :destroy]
    groups.resources :my_memberships, :only => [:create, :destroy]
    groups.resources :membership_requests #, :only => [:index, :create]
    groups.resources :invites, :only => [:new, :create]

    # settings related
    groups.resource  :settings, :only => [:show, :update]
    groups.resources :requests #, :only => [:index, :create]
    groups.resources :permissions, :only => [:index, :update]
    groups.resource  :profile, :only => [:edit, :update]
    groups.resource  :structure
 end

  ##
  ## DEBUGGING
  ##

  if Rails.env.development?
    map.debug_become 'debug/become', :controller => 'debug', :action => 'become'
    map.debug_break 'debug/break', :controller => 'debug', :action => 'break'
  end
  map.debug_report 'debug/report/submit', :controller => 'bugreport', :action => 'submit'

  ##
  ## NORMAL PAGE ROUTES
  ##

  # default page creator
  map.page_creation '/pages/:action/:owner/:type', :controller => 'pages/create',
    :action => 'create', :owner => 'me', :type => nil,
    :requirements => {:action => /new|create/}

  # base page
  map.resources :pages, :namespace => 'pages/', :controller => 'base' do |pages|
    pages.resources :participations, :only => [:index, :update, :create]
    pages.resources :changes
    pages.resources :assets, :only => [:index, :update, :create]
    pages.resources :tags
    pages.resources :posts, :member => {:edit => :any}, :only => [:show, :create, :edit, :update]

    # page sidebar/popup controllers:
    pages.resource :sidebar,    :only => [:show]
    pages.resource :share,      :only => [:show, :update]
    pages.resource :details,    :only => [:show]
    pages.resource :history,    :only => [:show], :controller => 'history'
    pages.resource :attributes, :only => [:update]
    pages.resource :title,      :only => [:edit, :update], :controller => 'title'
    pages.resource :trash,      :only => [:edit, :update], :controller => 'trash'
  end

  # page subclasses, gets triggered for any controller class Pages::XxxController
  map.connect '/pages/:controller/:action/:page_id', :constraints => {:controller => /.*_page/ }

  ##
  ## WIKI
  ##

  map.resources :wikis,
    :namespace => 'wikis/',
    :only => [:show, :edit, :update],
    :member => {:print => :get} do |wikis|
    wikis.resource :lock, :only  => [:destroy, :update]
    wikis.resources :assets, :only => [:new, :create]
    wikis.resources :versions, :only  => [:index, :show], :member => {:revert => :post}
    #wikis.resources :diffs, :only => [:show]
    #wikis.resources :sections, :only => [:edit, :update]
  end

  ##
  ## OTHER ROUTES
  ##

  map.root :controller => 'root'
  map.with_options(:path_prefix => 'do') do |map|
    map.connect '/static/:action/:id', :controller => 'static'
  end

  ## ADD ROUTES FROM MODS

  if Crabgrass.mod_route_blocks
    Crabgrass.mod_route_blocks.each do |block|
      block.call(map)
    end
  end

  ##
  ## SPECIAL PATH ROUTES for PAGES and ENTITIES
  ##

  map.connect ':_context/:_page(/*path)', :controller => 'dispatch', :action => 'dispatch'
  map.connect ':_context',              :controller => 'dispatch', :action => 'dispatch'
end

