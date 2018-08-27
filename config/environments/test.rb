Crabgrass::Application.configure do
  ##
  ## STANDARD RAILS OPTIONS
  ##

  # set to true if you use a tool that preloads your test environment
  config.eager_load = false
  config.cache_classes = !defined?(UNIT_TESTING)
  config.action_controller.perform_caching             = false
  config.action_controller.allow_forgery_protection    = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: 'localhost' }

  # use the exceptions app
  config.action_dispatch.show_exceptions = true
  config.consider_all_requests_local = false

  # Configure static asset server for tests with Cache-Control for performance
  config.public_file_server.enabled = true
  config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }

  # Use SQL instead of Active Record's schema dumper when creating the
  # test database.  This is necessary if your schema can't be completely
  # dumped by the schema dumper, like if you have constraints or
  # database-specific column types
  # config.active_record.schema_format = :sql

  # rails 5 like behaviour
  config.active_support.test_order = :random

  ##
  ## CRABGRASS OPTIONS
  ##

  ENV['INFO'] ||= '0'

  Conf.remote_processing = 'http://localhost:3002' if ENV['REMOTE']

#  ENV['GPGKEY'] = Rails.root.join('assets','keyfile', 'robot_secret_key.asc').to_s

  ##
  ## DEBUGGING
  ## See doc/DEBUGGING for tips.
  ##

  require "crabgrass/debug.rb"

  # additional config from rails app:update task to Rails 5.1

  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.seconds.to_i}"
  }

  config.action_mailer.perform_caching = false


  ##
  ## DEBUGGING
  ## See doc/DEBUGGING for tips.
  ##
  # Print deprecation notices to the stderr.
  #config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

end
