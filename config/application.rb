require_relative "../lib/crabgrass/info.rb"


info "LOAD FRAMEWORK"
require_relative 'boot'

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

require_relative "../lib/crabgrass/boot.rb"
require_relative "../lib/crabgrass/public_exceptions.rb"

module Crabgrass
  class Application < Rails::Application
    info "LOAD CONFIG BLOCK"

    config.autoload_paths << "#{Rails.root}/lib"
    config.autoload_paths << "#{Rails.root}/app/models"

    config.autoload_paths += %w(activity assets associations discussion chat profile poll task requests mailers notice).
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

    config.active_support.deprecation = :notify

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    #
    # We use strong parameters instead like rails4 does.
    #config.active_record.whitelist_attributes = true

    config.session_store :cookie_store,
      :key => 'crabgrass_session'

    config.secret_token = Conf.secret

    # Enable the asset pipeline
    config.assets.enabled = true
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    # We serve assets from /static because /assets is already used
    config.assets.prefix = '/static'

    # store fragments on disk, we might have a lot of them.
    config.action_controller.cache_store = :file_store, CACHE_DIRECTORY

    # add our custom 404 error class
    config.action_dispatch.rescue_responses.merge!(
      'ErrorNotFound' => :not_found
    )
    # Make Active Record use UTC-base instead of local time
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # Deliveries are disabled by default. Do NOT modify this section.
    # Define your email configuration in email.yml instead.
    # It will automatically turn deliveries on
    config.action_mailer.perform_deliveries = false

    config.exceptions_app = Crabgrass::PublicExceptions.new(Rails.public_path)

    ##
    ## PLUGINS
    ##

    config.before_configuration do
      Pathname.glob(CRABGRASS_PLUGINS_DIRECTORY + '*').each do |plugin|
        info "LOAD #{plugin.basename.to_s.humanize}"
        $:.unshift plugin + 'lib'
        require plugin + 'init.rb'
      end

      # TODO: respect Conf.enabled_pages, ENV['PAGE'] 'page' and ENV['PAGE'] ALL
      Pathname.glob(PAGES_DIRECTORY + '*/lib/*_page.rb').each do |page|
        info "LOAD #{page.basename('.rb').to_s.humanize}"
        require page
      end
    end

    #
    # Reload the permissions when reloading models in development and once
    # in production.
    # (They monkeypatch the User and Group classes.)
    config.to_prepare do
      CastleGates.initialize('config/permissions')
    end

    initializer "crabgrass_page.freeze_pages" do |app|
      require 'crabgrass/page/class_registrar'
      ::PAGES = Crabgrass::Page::ClassRegistrar.proxies.dup.freeze
      Conf.available_page_types = PAGES.keys if Conf.available_page_types.empty?
    end

  end

  ## FIXME: require these, where they are actually needed (or fix autoloading).
  require 'int_array'
  require 'crabgrass/validations'
  require 'crabgrass/page/class_proxy'
  require 'crabgrass/page/class_registrar'
  require 'crabgrass/page/data'

end
