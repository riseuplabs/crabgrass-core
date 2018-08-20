require 'active_support'

#
# This class provides access to config/crabgrass.RAILS_ENV.yml.
#
# The variables defined there are available as Config.varname
#
class Conf
  ##
  ## CLASS ATTRIBUTES
  ##

  # global options
  # Attributes that define behaviour of the whole install.
  # They cannot be differentiated based on domain
  cattr_accessor :name
  cattr_accessor :available_page_types
  cattr_accessor :tracking
  cattr_accessor :evil
  cattr_accessor :enforce_ssl
  cattr_accessor :profiles
  cattr_accessor :profile_fields
  cattr_accessor :require_user_email
  cattr_accessor :enabled_pages
  cattr_accessor :enabled_languages
  cattr_accessor :enabled_languages_hash # (private)
  cattr_accessor :email
  cattr_accessor :sites
  cattr_accessor :paranoid_emails
  cattr_accessor :ensure_page_owner
  cattr_accessor :default_page_access
  cattr_accessor :default_group_permissions
  cattr_accessor :default_user_permissions
  cattr_accessor :remote_processing
  cattr_accessor :committees
  cattr_accessor :councils
  cattr_accessor :networks
  cattr_accessor :transifex_user
  cattr_accessor :transifex_password
  cattr_accessor :log_level

  # Default values for site objects. If a site does not have
  # a value defined for one of these, we use the default in
  # the config file, or defined here.
  cattr_accessor :domain
  cattr_accessor :title
  cattr_accessor :theme
  cattr_accessor :pagination_size
  cattr_accessor :default_language
  cattr_accessor :email_sender
  cattr_accessor :email_sender_name
  cattr_accessor :dev_email
  cattr_accessor :show_exceptions
  cattr_accessor :login_redirect_url

  # Global options that are set automatically by the code
  # Typically, you will never have to configured these.
  cattr_accessor :enabled_site_ids

  # used for error reporting
  cattr_accessor :configuration_filename

  # used to run the tests even though the translations are messed up
  cattr_accessor :raise_i18n_exceptions

  # cattr_accessor doesn't work with ?
  def self.limited?
    limited
  end

  def self.paranoid_emails?
    paranoid_emails
  end

  def self.tracking?
    tracking
  end

  def self.ensure_page_owner?
    ensure_page_owner
  end

  ##
  ## LOADING
  ##

  def self.load_defaults
    self.name = 'default'

    # site defaults
    self.title             = 'crabgrass'
    self.pagination_size   = 30
    self.default_language  = 'en'
    self.email_sender      = 'robot@$current_host'
    self.email_sender_name = '$site_title ($user_name)'
    self.tracking          = true
    self.evil              = {}
    self.available_page_types = []
    self.enforce_ssl       = true
    self.show_exceptions   = false
    self.domain            = 'localhost'
    self.dev_email         = ''
    self.login_redirect_url = '/me'
    self.theme = 'default'

    # global configuration
    self.enabled_pages = []
    self.enabled_languages = []
    self.email         = nil
    self.sites         = {}
    self.ensure_page_owner = true
    self.default_page_access = :admin
    self.default_group_permissions = {
      'members' => :all,
      'public' => %w[view request_membership]
    }
    self.default_user_permissions = {
      'friends' => %i[view pester see_groups see_contacts],
      'peers' => %i[pester request_contact],
      'public' => []
    }
    self.remote_processing = false
    self.committees = true
    self.councils = true
    self.networks = true
    self.log_level = nil # use rails defaults
  end

  def self.load(filename)
    load_defaults
    self.configuration_filename = CRABGRASS_CONFIG_DIRECTORY + filename
    hsh = YAML.load_file(configuration_filename) || {}
    hsh.each do |key, value|
      method = key.to_s + '='
      if respond_to?(method)
        send(method, value) unless value.nil?
      else
        puts format("ERROR (%s): unknown option '%s'", configuration_filename, key)
      end
    end

    ## convert some strings in config to symbols
    ['default_page_access'].each do |conf_var|
      send(conf_var + '=', send(conf_var).to_sym)
    end

    ## convert enabled_languages into a hash
    self.enabled_languages_hash = Hash[(self.enabled_languages).zip(Array(1..self.enabled_languages.length))]

    true
  end

  ##
  ## SITES
  ##

  # can be called from a test's setup method in order to enable sites
  # for a particular set of tests without enabling sites for all tests.
  def self.enable_site_testing(site = nil)
    enabled_ids = site ? [site.id] : [1, 2]
    self.enabled_site_ids = enabled_ids
  end

  def self.disable_site_testing
    self.enabled_site_ids = []
  end

  ##
  ## LANGUAGE
  ##

  def self.language_enabled?(lang_code)
    enabled_languages_hash[lang_code]
  end
end
