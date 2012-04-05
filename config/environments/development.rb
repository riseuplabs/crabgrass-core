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
config.reload_plugins = true

##
## CRABGRASS OPTIONS
##

#
# When running crabgrass, you can set the environment variable
# INFO to a level 0 .. 10 to print out debugging messages.
# This sets the default level to 0, which shows the high level
# messages.
#
DEFAULT_INFO_LEVEL = 0

##
## GEMS
##

config.gem 'compass', :version => '~> 0.10'
config.gem 'haml', :version => '~> 3.0'
config.gem 'compass-susy-plugin', :lib => 'susy', :version => '0.8.1'

##
## DEBUGGING
## See doc/DEBUGGING for tips.
##

require "#{RAILS_ROOT}/lib/crabgrass/debug.rb"


## needed for rake tasks:
config.gem 'rdoc', :version => '~> 3.0'

