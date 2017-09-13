# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

use Rails::Rack::LogTailer unless Rails.env.test?

# byebug fails with this - so make sure we only load if with Debugger
use Rails::Rack::Debugger if defined?(Debugger) && Rails.env.development?

run Crabgrass::Application
