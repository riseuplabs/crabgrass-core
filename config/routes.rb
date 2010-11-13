unless defined?(FORBIDDEN_NAMES)
  FORBIDDEN_NAMES = %w(account admin assets avatars chat code debug do groups javascripts me networks page pages people places issues static stats stylesheets theme).freeze
end

ActionController::Routing::Routes.draw do |map|

  ##
  ## STATIC FILES AND ASSETS
  ##

  map.with_options(:controller => 'assets') do |assets|
    assets.connect '/assets/:action/:id', :action => /create|destroy/
    assets.connect 'assets/:id/versions/:version/*path', :action => 'show'
    assets.connect 'assets/:id/*path', :action => 'show'
  end

  map.avatar 'avatars/:id/:size.jpg', :controller => 'avatars', :action => 'show' 
  map.connect 'theme/:name/*file.css', :controller => 'theme', :action => 'show'

  ##
  ## ME
  ##

  map.with_options(:namespace => 'me/', :path_prefix => 'me', :name_prefix => 'me_') do |me|
    me.resources :notices
    me.home      '', :controller => 'notices', :action => 'index'
    me.resource  :page, :only => [:new, :create]
    me.pages     'pages/*path', :controller => 'pages'
    me.resources :activities
    me.resources(:discussions, :as => 'messages') do |discussion|
      discussion.resources :posts
    end
    me.resource  :settings, :only => [:show, :update]
    me.resources :permissions
    me.resource  :profile, :controller => 'profile'
    me.resources :requests
    me.resources :avatars
  end

  ##
  ## ENTITIES
  ##

  map.resources :entities, :only => [:index]

#  ##
#  ## PEOPLE
#  ##

#  map.people_directory 'people/directory/*path', :controller => 'people/directory'

#  map.resources :people, :namespace => 'people/' do |people|
#    people.resource  :page, :only => [:new, :create]
#    people.pages     'pages/*path', :controller => 'pages'
#    people.resources :messsages
#    people.resources :activities
#    people.resources :pages
#  end

#  ##
#  ## EMAIL
#  ##

#  map.connect '/invites/:action/*path', :controller => 'requests', :action => /accept/
#  map.connect '/code/:id', :controller => 'codes', :action => 'jump'

#  ##
#  ## ACCOUNT
#  ##

  map.with_options(:controller => 'account') do |account|
    account.reset_password 'account/reset_password/:token', :action => 'reset_password'
    account.account_verify 'account/verify_email/:token', :action => 'verify_email'
    account.connect 'account/:action/:id'
  end

  map.with_options(:controller => 'session') do |session|
    session.login 'session/login', :action => 'login'
    session.logout 'session/logout', :action => 'logout'
  end

#  ##
#  ## GROUP
#  ##

  map.networks_directory 'networks/directory/*path', :controller => 'groups/networks_directory'
  map.groups_directory 'groups/directory/*path', :controller => 'groups/groups_directory'

#  map.resources :groups, :networks, :namespace => 'groups/' do |groups|
#    groups.resource  :page, :only => [:new, :create]
#    groups.pages     'pages/*path', :controller => 'pages' #, :path => []
#    groups.resources :members
#    groups.resources :requests
#    groups.resources :invites
#    groups.resource  :settings, :only => [:show, :update]
#  end

#  ##
#  ## DEBUGGING
#  ##

  if RAILS_ENV == "development"
    ## DEBUG ROUTE
    map.debug_become 'debug/become', :controller => 'debug', :action => 'become'
  end
  map.debug_report 'debug/report/submit', :controller => 'bugreport', :action => 'submit'

  ##
  ## DEFAULT ROUTE
  ##

  map.connect '/do/:controller/:action/:id'
  map.root :controller => 'root'

#  ##
#  ## PAGES and ENTITY LANDING
#  ##

#  map.connect '/pages/:controller/:action/:id', :controller => /base_page\/[^\/]+/
#  map.connect 'pages/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil
#  map.connect ':_context/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil
#  map.connect ':_context', :controller => 'dispatch', :action => 'dispatch', :_page => nil

end
