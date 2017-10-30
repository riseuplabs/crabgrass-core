Crabgrass::Application.configure do
  ##
  ## STANDARD RAILS OPTIONS
  ##

  config.eager_load = false
  config.cache_classes = false
  config.assets.compress = false
  config.assets.debug = true
  config.consider_all_requests_local = false
  # config.action_view.debug_rjs                         = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.log_level = Conf.log_level || :debug

  config.action_mailer.default_url_options = { host: 'localhost' }

# # FIXME: for mailcatcher - does not work yet
#  config.action_mailer.delivery_method = :smtp
#  config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }

  ## FIXME: when reloading plugins is enabled, SearchFilter.filters will be
  ##        empty after the first request.
  config.reload_plugins = false

  ##
  ## CRABGRASS OPTIONS
  ##

  #
  # When running crabgrass, you can set the environment variable
  # INFO to a level 0 .. 10 to print out debugging messages.
  # This sets the default level to 0, which shows the high level
  # messages.
  #
  ENV['INFO'] ||= '0'

  ##
  ## DEBUGGING
  ## See doc/DEBUGGING for tips.
  ##

  require "#{Rails.root}/lib/crabgrass/debug.rb"
end
