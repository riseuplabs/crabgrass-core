# The internationalization framework can be changed
# to have another default locale (standard is :en) or more load paths.
# All files from config/locales/*.rb,yml are added automatically.

# glob all locales in the config/locales folder
locale_paths = Dir[File.join(Rails.root, 'config', 'locales', '**', '*.{rb,yml}')]

# select only enabled locales unless no enabled locales are set
if Conf.enabled_languages.any?
  locale_paths = locale_paths.select do |path|
    Conf.enabled_languages.detect do |enabled_lang_code|
      path.include?('/en/') or path.include?("#{enabled_lang_code}.yml")
    end
  end
end

# put override paths last
Dir[File.join(LOCALE_OVERRIDE_DIRECTORY, '*.yml')].each do |path|
  locale_paths << path
end

# set the load paths
I18n.load_path << locale_paths
I18n.default_locale = Conf.default_language
I18n.exception_handler = :crabgrass_i18n_exception_handler

##
## Turn off reloading of .yml files after every request if in BOOST mode.
##

if ENV['BOOST']
  module SkipReloading
    def skip_reload!
    end
    def self.included(backend)
      backend.class_eval do
        alias_method :reload_for_real!, :reload!
        alias_method :reload!, :skip_reload!
      end
    end
  end
  I18n::Backend::Simple.send(:include, SkipReloading)
end

