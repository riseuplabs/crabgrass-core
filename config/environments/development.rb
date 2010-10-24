##
## STANDARD RAILS OPTIONS
##

config.cache_classes = false
config.whiny_nils = true
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
config.action_mailer.raise_delivery_errors = false
config.log_level = :debug

##
## CRABGRASS OPTIONS
##

ASSET_PRIVATE_STORAGE = "#{RAILS_ROOT}/test/fixtures/assets"
ASSET_PUBLIC_STORAGE  = "#{RAILS_ROOT}/public/assets"
KEYRING_STORAGE       = "#{RAILS_ROOT}/test/fixtures/assets/keyrings"

##
## DEBUGGING
## See doc/DEBUGGING for tips. 
##

require "#{RAILS_ROOT}/lib/crabgrass/debug.rb"


