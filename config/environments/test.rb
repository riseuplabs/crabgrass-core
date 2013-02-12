Crabgrass::Application.configure do
  ##
  ## Unit tests can run in a stripped down environment.
  ##

  if defined? UNIT_TESTING
    config.eager_load_paths = ["#{Rails.root}/app/models"]
    #config.frameworks=[:active_record, :action_mailer, :action_view]
    config.autoload_paths = ["#{Rails.root}/app/models/"]
    config.autoload_paths += %w(activity assets associations discussion chat observers profile poll task tracking requests mailers).collect{|dir|"#{Rails.root}/app/models/#{dir}"}
  end

  ##
  ## STANDARD RAILS OPTIONS
  ##

  config.cache_classes = !defined?(UNIT_TESTING)
  config.whiny_nils = true
  config.action_controller.consider_all_requests_local = true
  config.action_controller.perform_caching             = false
  config.action_view.cache_template_loading            = true
  config.action_controller.allow_forgery_protection    = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { :host => "localhost" }

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  ##
  ## CRABGRASS OPTIONS
  ##

  DEFAULT_INFO_LEVEL = 0

  if ENV["REMOTE"]
    Conf.remote_processing = 'http://localhost:3002'
  end

  ##
  ## DEBUGGING
  ## See doc/DEBUGGING for tips.
  ##

  require "#{Rails.root}/lib/crabgrass/debug.rb"
end
