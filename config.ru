# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# unless Rails.env.production?
#   map '/static' do
#     sprockets = Sprockets::Environment.new
#     #sprockets.append_path 'app/assets/images'
#     sprockets.append_path 'app/assets/javascripts'
#     #sprockets.append_path 'app/assets/stylesheets'

#     # gem sprockets-helpers:
#     # (i can't figure out how to get this to work with rails 2)
#     #Sprockets::Helpers.configure do |config|
#     #  config.environment = sprockets
#     #  config.prefix      = "/static"
#     #  config.digest      = false
#     #end

#     run sprockets
#   end
# end

use Rails::Rack::LogTailer unless Rails.env.test?
use Rails::Rack::Debugger if Rails.env.development?
run Crabgrass::Application
