#
# When run via mod_rails/passenger, passenger will set the environment variable
# RACK_ENV because it detects the file config.ru. Yes, this is a rack app, but
# running rails 2.3... which needs RAILS_ENV to be set, not RACK_ENV.
#
if ENV["RACK_ENV"]
  ENV["RAILS_ENV"] = ENV["RACK_ENV"]
end

# we need to protect against multiple includes of the Rails environment (trust me)
require 'config/environment' if !defined?(Rails) || !Rails.initialized?
require 'sprockets'

unless Rails.env.production?
  map '/static' do
    sprockets = Sprockets::Environment.new
    #sprockets.append_path 'app/assets/images'
    sprockets.append_path 'app/assets/javascripts'
    #sprockets.append_path 'app/assets/stylesheets'

    # gem sprockets-helpers:
    # (i can't figure out how to get this to work with rails 2)
    #Sprockets::Helpers.configure do |config|
    #  config.environment = sprockets
    #  config.prefix      = "/static"
    #  config.digest      = false
    #end

    run sprockets
  end
end

map '/' do
  use Rails::Rack::LogTailer unless Rails.env.test?
  use Rails::Rack::Debugger unless Rails.env.test?
  use Rails::Rack::Static
  run ActionController::Dispatcher.new
end
