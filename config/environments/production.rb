##
## STANDARD RAILS OPTIONS
##

config.cache_classes = true
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

##
## LOGGING
##

config.log_level = :warn

begin
  # use syslog if available
  config.gem 'log4r', :version => '>=1.1.0'
  require 'log4r/outputter/syslogoutputter'
  config.logger = Log4r::Logger.new('main')
  config.logger.outputters = Log4r::SyslogOutputter.new('crabgrass')
  config.logger.info "initializing production server"
rescue LoadError => exc
  # i guess there is no log4r
end

ANALYZABLE_PRODUCTION_LOG = "/var/log/rails.log"

##
## CRABGRASS OPTIONS
##

ASSET_PRIVATE_STORAGE = "#{RAILS_ROOT}/assets"
ASSET_PUBLIC_STORAGE  = "#{RAILS_ROOT}/public/assets"
KEYRING_STORAGE = "#{RAILS_ROOT}/assets/keyrings"

