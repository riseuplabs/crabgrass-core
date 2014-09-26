require 'active_support'

#
# This class provides access to config/crabgrass.RAILS_ENV.yml.
#
# The variables defined there are available as Config.varname
#
class Conf

  ##
  ## CONSTANTS
  ##

  TEXT_EDITOR = Hash.new(0).merge({
    greencloth_only: 0,        html_only: 1,
    greencloth_preferred: 2,   html_preferred: 3
  }).freeze

  ##
  ## CLASS ATTRIBUTES
  ## (these are ok, because they are shared among all sites)
  ##

  # Site attributes that can only be specified in crabgrass.*.yml.
  cattr_accessor :name

  # Default values for site objects. If a site does not have
  # a value defined for one of these, we use the default in
  # the config file, or defined here.
  cattr_accessor :title
  cattr_accessor :pagination_size
  cattr_accessor :default_language
  cattr_accessor :email_sender
  cattr_accessor :email_sender_name
  cattr_accessor :available_page_types
  cattr_accessor :tracking
  cattr_accessor :evil
  cattr_accessor :enforce_ssl
  cattr_accessor :show_exceptions
  cattr_accessor :require_user_email
  cattr_accessor :require_user_full_info
  cattr_accessor :domain
  cattr_accessor :translation_group
  cattr_accessor :chat
  cattr_accessor :dev_email
  cattr_accessor :login_redirect_url
  cattr_accessor :theme

  # are in site, but I think they should be global
  cattr_accessor :translators
  cattr_accessor :translation_group

  # are global, but might end up in site one day.
  cattr_accessor :profiles
  cattr_accessor :profile_fields
  cattr_accessor :limited

  # global options
  cattr_accessor :enabled_mods
  cattr_accessor :enabled_tools # deprecated
  cattr_accessor :enabled_pages
  cattr_accessor :enabled_languages
  cattr_accessor :enabled_languages_hash # (private)
  cattr_accessor :email
  cattr_accessor :sites
  cattr_accessor :secret
  cattr_accessor :paranoid_emails
  cattr_accessor :ensure_page_owner
  cattr_accessor :default_page_access
  cattr_accessor :default_group_permissions
  cattr_accessor :default_user_permissions
  cattr_accessor :text_editor
  cattr_accessor :use_full_geonames_data
  cattr_accessor :remote_processing
  cattr_accessor :committees
  cattr_accessor :councils
  cattr_accessor :networks
  cattr_accessor :transifex_user
  cattr_accessor :transifex_password


  # set automatically from site.admin_group
  cattr_accessor :super_admin_group_id

  # Global options that are set automatically by the code
  # Typically, you will never have to configured these.
  cattr_accessor :enabled_site_ids

  # used for error reporting
  cattr_accessor :configuration_filename

  # used to run the tests even though the translations are messed up
  cattr_accessor :raise_i18n_exceptions

  # cattr_accessor doesn't work with ?
  def self.chat?; self.chat; end
  def self.limited?; self.limited; end
  def self.paranoid_emails?; self.paranoid_emails; end
  def self.tracking?; self.tracking; end
  def self.ensure_page_owner?; self.ensure_page_owner; end

  ##
  ## LOADING
  ##

  def self.load_defaults
    self.name                 = 'default'
    self.super_admin_group_id = nil

    # site defaults
    self.title             = 'crabgrass'
    self.pagination_size   = 30
    self.default_language  = 'en'
    self.email_sender      = 'robot@$current_host'
    self.email_sender_name = '$site_title ($user_name)'
    self.tracking          = false
    self.evil              = {}
    self.available_page_types = []
    self.enforce_ssl       = false
    self.show_exceptions   = true
    self.domain            = 'localhost'
    self.chat              = true
    self.dev_email         = ''
    self.login_redirect_url = '/me'
    self.theme             = 'default'

    # global configuration
    self.enabled_mods  = []
    self.enabled_tools = [] # deprecated
    self.enabled_pages = []
    self.enabled_languages = []
    self.email         = nil
    self.sites         = []
    self.secret        = nil
    self.ensure_page_owner = true
    self.default_page_access = :admin
    self.default_group_permissions = {
      'members' => :all,
      'public' => ['view', 'request_membership']
    }
    self.default_user_permissions = {
      'friends' => [:view, :pester, :see_groups, :see_contacts],
      'peers' => [:pester, :request_contact],
      'public' => []
    }
    self.text_editor   = TEXT_EDITOR[:greencloth_only]
    self.use_full_geonames_data = false
    self.remote_processing = false
    self.committees = true
    self.councils = true
    self.networks = true
  end

  def self.load(filename)
    self.load_defaults
    self.configuration_filename = CRABGRASS_CONFIG_DIRECTORY + filename
    hsh = YAML.load_file(configuration_filename) || {}
    hsh.each do |key, value|
      method = key.to_s + '='
      if self.respond_to?(method)
        self.send(method,value) unless value.nil?
      else
        puts "ERROR (%s): unknown option '%s'" % [configuration_filename,key]
      end
    end

    ## convert strings in config to numeric constants.
    const = ("Conf::TEXT_EDITOR").constantize
    attr = ("TEXT_EDITOR").downcase
    if self.send(attr).is_a? String
      unless const.has_key? self.send(attr).to_sym
        raise Exception.new('%s of "%s" is not recognized' % [attr, self.send(attr)])
      end
      self.send(attr+'=', const[self.send(attr).to_sym])
    end

    ## convert some strings in config to symbols
    ['default_page_access'].each do |conf_var|
      self.send(conf_var+'=', self.send(conf_var).to_sym)
    end

    ## convert enabled_languages into a hash
    self.enabled_languages_hash = self.enabled_languages.to_h {|i| [i, true]}

    return true
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
  ## PLUGINS
  ##

  # This is a callback method that we set in lib/crabgrass/boot.rb.
  # We should return true if we want the plugin to be loaded, false otherwise.
  def self.plugin_enabled?(plugin_path)
    if plugin_path =~ /^#{Regexp.escape(MODS_DIRECTORY)}\/[^\/]+$/
      self.mod_enabled?( File.basename(plugin_path) )
    elsif plugin_path =~ /^#{Regexp.escape(PAGES_DIRECTORY)}\/[^\/]+$/
      self.page_enabled?( File.basename(plugin_path) )
    else
      true
    end
  end

  ##
  ## LANGUAGE
  ##

  def self.language_enabled?(lang_code)
    self.enabled_languages_hash[lang_code]
  end

  private

  # a mod will be enabled if explicitly configured to be so, or if
  # ENV['MOD'] is set.
  def self.mod_enabled?(mod_name)
    self.enabled_mods.include?(mod_name) or
    ENV['MOD'] == mod_name or
    ENV['MOD'] == 'ALL'
  end

  # page definitions are like mods, except that the default is to enable them all.
  # unless only some are enabled.
  def self.page_enabled?(page_name)
    enabled_list = self.enabled_pages || self.enabled_tools
    enabled_list.empty? or enabled_list.include?(page_name) or ENV['PAGE'] == page_name
  end

  public

  # in development mode, allow all pages to be reloadable
  def self.plugin_reloadable?(plugin_path)
    plugin_path.starts_with?(PAGES_DIRECTORY)
  end

  ##
  ## CONVENIENCE METHODS
  ##

  public

  def self.allow_greencloth_editor?
    self.text_editor != TEXT_EDITOR[:html_only]
  end

  def self.allow_html_editor?
    self.text_editor != TEXT_EDITOR[:greencloth_only]
  end

  def self.text_editor_sym
    @@text_editor_symbols ||= TEXT_EDITOR.invert
    @@text_editor_symbols[self.text_editor]
  end

end


