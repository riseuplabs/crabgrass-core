require 'rubygems'

require 'test/unit'

require 'action_pack'
require 'action_controller'
require 'action_controller/base' # <- not sure why this is necessary
# but ActionController::RouteError doesn't load
# without it.
require 'action_view'

require 'active_support'
require 'active_support/test_case'

$LOAD_PATH << File.dirname(__FILE__) + '/..'
require 'init'
require 'app/helpers/modalbox_helper'

# def dbg
#  require 'ruby-debug'
#  Debugger.start
#  debugger
# end
