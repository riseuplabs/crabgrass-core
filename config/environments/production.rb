Crabgrass::Application.configure do
  ##
  ## STANDARD RAILS OPTIONS
  ##

  config.cache_classes = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = true
  #config.action_view.cache_template_loading            = true

  ##
  ## LOGGING
  ## use syslog if available, trying gems 'logging' and 'SyslogLogger'
  ##

  config.log_level = :debug

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
