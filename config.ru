# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

use Rails::Rack::LogTailer unless Rails.env.test?
use Rails::Rack::Debugger if Rails.env.development?
run Crabgrass::Application
