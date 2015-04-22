Crabgrass::Application.configure do

  ##
  ## STANDARD RAILS OPTIONS
  ##

  config.cache_classes = !defined?(UNIT_TESTING)
  config.whiny_nils = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = false
  config.action_controller.allow_forgery_protection    = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { :host => "localhost" }

  ## Rails 3.1
  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = 'public, max-age=3600'

  ## Rails 3.2
  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  ##
  ## CRABGRASS OPTIONS
  ##

  ENV['INFO'] ||= "0"

  if ENV["REMOTE"]
    Conf.remote_processing = 'http://localhost:3002'
  end

  ##
  ## DEBUGGING
  ## See doc/DEBUGGING for tips.
  ##

  require "#{Rails.root}/lib/crabgrass/debug.rb"
end
