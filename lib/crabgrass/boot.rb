module Crabgrass
end

# load our core extends early, since they might be use anywhere.
Dir.glob("#{RAILS_ROOT}/lib/extends/*.rb").each do |file|
  require file
end

# load the mods plugin first, it modifies how the plugin loading works
require "#{RAILS_ROOT}/vendor/crabgrass_plugins/crabgrass_mods/rails/boot"

# load Crabgrass::Initializer early, it is used in environment.rb
require File.dirname(__FILE__) + '/initializer'

# do this early because environments/*.rb need it
require File.dirname(__FILE__) + '/conf'

# load configuration file
Conf.load("crabgrass/crabgrass.#{RAILS_ENV}.yml")

# control which plugins get loaded and are reloadable
Mods.plugin_enabled_callback = Conf.method(:plugin_enabled?)
Mods.plugin_reloadable_callback = Conf.method(:plugin_reloadable?)

begin
  secret_path = File.join(RAILS_ROOT, "config", "crabgrass", "secret.txt")
  Conf.secret = File.read(secret_path).chomp
rescue
  unless ARGV.first == "create_a_secret"
    raise "Can't load the secret key from file #{secret_path}. Have you run 'rake create_a_secret'?"
  end
end

