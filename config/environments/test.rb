##
## STANDARD RAILS OPTIONS
##

config.cache_classes = true
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
## GEMS REQUIRED FOR TESTS
##

config.gem 'machinist', :version => '~> 1.0' # switch to v2 when stable.
config.gem 'faker'
config.gem 'minitest', :lib => 'minitest/autorun'

#config.gem 'webrat'

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

require "#{RAILS_ROOT}/lib/crabgrass/debug.rb"
