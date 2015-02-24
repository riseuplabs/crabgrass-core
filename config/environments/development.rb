Crabgrass::Application.configure do

  #
  # Enable/disable rails-dev-boost.
  # This needs to be done before initializers are loaded, after gem is loaded.
  #
  class RailsDevelopmentBoost::Railtie
    class << self
      def boost_enabled_with_env_toggle?
        ENV['BOOST'] && boost_enabled_without_env_toggle?
      end
      alias_method_chain :boost_enabled?, :env_toggle
    end
  end

  ##
  ## STANDARD RAILS OPTIONS
  ##

  config.cache_classes = false
  config.whiny_nils = true
  config.assets.compress = false
  config.assets.debug = true
  config.consider_all_requests_local = true
  #config.action_view.debug_rjs                         = true
  config.action_controller.perform_caching              = true
  config.action_mailer.raise_delivery_errors = false
  config.log_level = Conf.log_level || :debug

  ## FIXME: when reloading plugins is enabled, SearchFilter.filters will be
  ##        empty after the first request.
  config.reload_plugins = false
  config.active_support.deprecation = :log


  ##
  ## Upgrade to Rails 3.2
  ##

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5


  ##
  ## CRABGRASS OPTIONS
  ##

  #
  # When running crabgrass, you can set the environment variable
  # INFO to a level 0 .. 10 to print out debugging messages.
  # This sets the default level to 0, which shows the high level
  # messages.
  #
  ENV['INFO'] ||= "0"

  ##
  ## DEBUGGING
  ## See doc/DEBUGGING for tips.
  ##

  require "#{Rails.root}/lib/crabgrass/debug.rb"
end
