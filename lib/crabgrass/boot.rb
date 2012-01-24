module Crabgrass
end

# do this early because environments/*.rb need it, as do some of the files in lib/extends
require File.dirname(__FILE__) + '/conf'

# load our core extends early, since they might be use anywhere.
# active_support needs to be required before this, so we get methods like alias_method_chain
Dir.glob("#{RAILS_ROOT}/lib/extends/*.rb").each do |file|
  require file
end

# load the mods plugin first, it modifies how the plugin loading works
require "#{CRABGRASS_PLUGINS_DIRECTORY}/crabgrass_mods/rails/boot"

# load Crabgrass::Initializer early, it is used in environment.rb
require File.dirname(__FILE__) + '/initializer'

# load configuration file
Conf.load("crabgrass.#{RAILS_ENV}.yml")

# control which plugins get loaded and are reloadable
Mods.plugin_enabled_callback = Conf.method(:plugin_enabled?)
Mods.plugin_reloadable_callback = Conf.method(:plugin_reloadable?)

begin
  Conf.secret = File.read(CRABGRASS_SECRET_FILE).chomp
rescue
  unless ARGV.first == "create_a_secret"
    raise "Can't load the secret key from file #{CRABGRASS_SECRET_FILE}. Have you run 'rake create_a_secret'?"
  end
end

