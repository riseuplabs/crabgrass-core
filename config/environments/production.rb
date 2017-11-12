Crabgrass::Application.configure do
  ##
  ## STANDARD RAILS OPTIONS
  ##

  config.eager_load = true
  config.cache_classes = true
  config.action_controller.perform_caching = true

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Precompile additional assets (application.js, application.css, and
  # all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  ##
  ## EXPOSED CONFIG OPTIONS
  ##
  ## These are config options we fetch from crabgrasses own Conf so you can
  ## set them in config/crabgrass/*_config.rb

  # fall back to rails3 default - rails4 has debug
  config.log_level = Conf.log_level || :info
  config.consider_all_requests_local = Conf.show_exceptions

  # Force all access to the app over TLS, use Strict-Transport-Security,
  # and use secure cookies.
  # You will want to set this even if you have redirects to enforce TLS
  # because of the secure cookies
  config.force_ssl = Conf.enforce_ssl

  ##
  ## LOGGING
  ## use syslog if available, trying gems 'logging' and 'SyslogLogger'
  ##

  # try gem 'logging'
  begin
    require 'logging'
    config.logger = Logging::Logger['main'].tap do |l|
      l.add_appenders(Logging::Appenders::Syslog.new('crabgrass'))
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

  # we filter almost everything. Logs are only detailed for performance
  # analysis.
  # For debugging having the ids of the records should suffice.
  config.filter_parameters += %i[body description name summary comment]
  config.filter_parameters += %i[caption code email location im_address]
  config.filter_parameters += %i[title content data details organization role]
  config.filter_parameters += %i[value sms login]

  ANALYZABLE_PRODUCTION_LOG = '/var/log/rails.log'.freeze
end
