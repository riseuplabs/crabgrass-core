Crabgrass::Application.configure do
  ##
  ## STANDARD RAILS OPTIONS
  ##

  config.cache_classes = false
  config.whiny_nils = true
  config.consider_all_requests_local = true
  config.action_view.debug_rjs                         = true
  config.action_controller.perform_caching             = false
  config.action_mailer.raise_delivery_errors = false
  config.log_level = :debug

  ## FIXME: when reloading plugins is enabled, SearchFilter.filters will be
  ##        empty after the first request.
  config.reload_plugins = false

  config.active_support.deprecation = :log

  ##
  ## CRABGRASS OPTIONS
  ##

  #
  # When running crabgrass, you can set the environment variable
  # INFO to a level 0 .. 10 to print out debugging messages.
  # This sets the default level to 0, which shows the high level
  # messages.
  #
  DEFAULT_INFO_LEVEL = 0

  ##
  ## DEBUGGING
  ## See doc/DEBUGGING for tips.
  ##

  require "#{Rails.root}/lib/crabgrass/debug.rb"
end
