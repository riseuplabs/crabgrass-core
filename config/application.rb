require_relative "../lib/crabgrass/info.rb"

info "LOAD FRAMEWORK"
require_relative 'boot'

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line

  ## THE FOLLOWING LINE WAS ADDED BY rails 3.2 GENERATOR. REMOVE THE COMMENT ONCE
  ## YOU'RE UPGRADING!
  #Bundler.require(*Rails.groups(:assets => %w(development test)))
  Bundler.require(:default, Rails.env)

  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

require_relative "../lib/crabgrass/boot.rb"

module Crabgrass
  class Application < Rails::Application
    info "LOAD CONFIG BLOCK"

    config.autoload_paths << "#{Rails.root}/lib"
    config.autoload_paths << "#{Rails.root}/app/models"

    config.autoload_paths += %w(activity assets associations discussion chat observers profile poll task tracking requests mailers notice).
     collect { |dir| "#{Rails.root}/app/models/#{dir}" }
    config.autoload_paths << "#{Rails.root}/app/permissions"
    config.autoload_paths << "#{Rails.root}/app/sweepers"
    config.autoload_paths << "#{Rails.root}/app/helpers/classes"

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true
    config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    #config.active_record.whitelist_attributes = true

    config.active_record.observers = :user_observer, :membership_observer,
    :group_observer, :relationship_observer, :post_observer,
    :request_to_destroy_our_group_observer, :request_observer, :page_observer,
    "tracking/page_observer", "tracking/post_observer", "tracking/wiki_observer",
    "tracking/user_participation_observer", "tracking/group_participation_observer"

    config.session_store :cookie_store #:mem_cache_store # :p_store

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
    config.plugins = [
      :crabgrass_mods,
      :after_reload,
      :crabgrass_path_finder,
      :all
    ]

    # allow plugins in more places
    [CRABGRASS_PLUGINS_DIRECTORY, MODS_DIRECTORY, PAGES_DIRECTORY, WIDGETS_DIRECTORY].each do |path|
      config.paths.vendor.plugins << path
    end

  end

  ## FIXME: require these, where they are actually needed (or fix autoloading).
  require 'int_array'
  require 'crabgrass/validations'
  require 'crabgrass/page/class_proxy'
  require 'crabgrass/page/class_registrar'
  require 'crabgrass/page/data'
  require 'crabgrass/mod_routes'

end
