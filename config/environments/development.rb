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

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  config.action_mailer.default_url_options = { host: 'localhost' }
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

  # FIXME: the following additional options were suggested by
  # rails app:update for Rails 5.1

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  #config.file_watcher = ActiveSupport::EventedFileUpdateChecker



end
