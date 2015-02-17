Crabgrass::Application.configure do
  ##
  ## STANDARD RAILS OPTIONS
  ##

  config.cache_classes = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = true
  #config.action_view.cache_template_loading            = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  ##
  ## LOGGING
  ## use syslog if available, trying gems 'logging' and 'SyslogLogger'
  ##
  
  # fall back to rails3 default - rails4 has debug
  config.log_level = Conf.log_level || :info

  # try gem 'logging'
  begin
    require 'logging'
    config.logger = Logging::Logger['main'].tap do |l|
      l.add_appenders( Logging::Appenders::Syslog.new('crabgrass') )
      l.level = config.log_level
    end
  rescue LoadError => exc
    # try gem 'SyslogLogger'
    # i am not sure how to turn down the verbosity with syslog.
    # even with config.log_level = :warn, it does debug logging.
    begin
      require 'syslog_logger'
      config.logger = SyslogLogger.new('crabgrass')
    rescue LoadError => exc
    end
  end

  ANALYZABLE_PRODUCTION_LOG = "/var/log/rails.log"
end
