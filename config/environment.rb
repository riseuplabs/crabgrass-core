require "#{File.dirname(__FILE__)}/../lib/crabgrass/info.rb"

info "LOAD FRAMEWORK"

# Use any Rails in the 2.3.x series, greater than or equal to 2.3.15
# 2.3.15 fixed a severe security issue. So we should not go below that.
RAILS_GEM_VERSION = '~>2.3.15'
require File.join(File.dirname(__FILE__), 'boot')
require "#{RAILS_ROOT}/config/directories.rb"
require "#{RAILS_ROOT}/lib/crabgrass/boot.rb"

Crabgrass::Initializer.run do |config|
  info "LOAD CONFIG BLOCK"

  config.autoload_paths += %w(activity assets associations discussion chat observers profile poll task tracking requests mailers notice).collect{|dir|"#{RAILS_ROOT}/app/models/#{dir}"}
  config.autoload_paths << "#{RAILS_ROOT}/app/permissions"
  config.autoload_paths << "#{RAILS_ROOT}/app/sweepers"
  config.autoload_paths << "#{RAILS_ROOT}/app/helpers/classes"

  # this is required because we have a mysql specific fulltext index.
  config.active_record.schema_format = :sql

  # observers that should always be running
  config.active_record.observers = :user_observer, :membership_observer,
    :group_observer, :relationship_observer, :post_observer, :page_tracking_observer,
    :request_to_destroy_our_group_observer, :request_observer, :page_observer

  config.action_controller.session_store = :cookie_store #:mem_cache_store # :p_store

  # store fragments on disk, we might have a lot of them.
  config.action_controller.cache_store = :file_store, CACHE_DIRECTORY

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  config.active_record.default_timezone = :utc

  # Deliveries are disabled by default. Do NOT modify this section.
  # Define your email configuration in email.yml instead.
  # It will automatically turn deliveries on
  config.action_mailer.perform_deliveries = false

  ##
  ## PLUGINS
  ##

  # we must load crabgrass_mods and load_model_callback first.
  config.plugins = [:crabgrass_mods, :after_reload, :all]

  # allow plugins in more places
  [CRABGRASS_PLUGINS_DIRECTORY, MODS_DIRECTORY, PAGES_DIRECTORY, WIDGETS_DIRECTORY].each do |path|
    config.plugin_paths << path
  end

  # See Rails::Configuration for more options
end

if defined?(User)
  #
  # This needs to be run last, after models are loaded. Sometimes, environment.rb is loaded
  # without models getting loaded. Hence, the defined?(User) test around this block.
  # It is hackish, but it works.
  #
  CastleGates.initialize('config/permissions')
end
