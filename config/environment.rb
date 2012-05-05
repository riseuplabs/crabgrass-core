require "#{File.dirname(__FILE__)}/../lib/crabgrass/info.rb"

info "LOAD FRAMEWORK"

# Use any Rails in the 2.3.x series, greater than or equal to 2.3.11
# latest rubygems needs at least 2.3.14 - but we don't have that on
# CI yet.
RAILS_GEM_VERSION = '~>2.3.11'
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

  # allow plugins in more places
  [CRABGRASS_PLUGINS_DIRECTORY, MODS_DIRECTORY, PAGES_DIRECTORY, WIDGETS_DIRECTORY].each do |path|
    config.plugin_paths << path
  end

  # Deliveries are disabled by default. Do NOT modify this section.
  # Define your email configuration in email.yml instead.
  # It will automatically turn deliveries on
  config.action_mailer.perform_deliveries = false

  ##
  ## GEMS
  ## see environments/test.rb for testing specific gems
  ##

  # required, but not included with crabgrass:
  config.gem 'i18n', :version => '~> 0.5'
  config.gem 'thinking-sphinx', :version => '~> 1.4'
  config.gem 'will_paginate', :version => '= 2.3.16'
  config.gem 'sprockets', "~> 2.1.0"

  # required, and compilation is required to install
  config.gem 'RedCloth', :version => '~> 4.2'
  config.gem 'hpricot', :version => '~> 0.8'

  # required, included with crabgrass
  config.gem 'riseuplabs-greencloth', :lib => 'greencloth'
  config.gem 'riseuplabs-undress', :lib => 'undress/greencloth'
  config.gem 'riseuplabs-uglify_html', :lib => 'uglify_html'

  # not required, but a really good idea
  config.gem 'mime-types', :lib => 'mime/types'

  # delayed job for rails 2.x:
  config.gem 'delayed_job', :version => '~> 2.0.7'

  if Rails.env == 'production' || Rails.env == 'development'
    config.gem 'compass', :version => '0.10.6'
    config.gem 'haml', :version => '~> 3.0'
    config.gem 'compass-susy-plugin', :lib => 'susy', :version => '0.8.1'
    config.gem 'whenever'
  end

  # See Rails::Configuration for more options
end

