#
# Set the load paths for locale translations files.
#

#
# glob all locales in the config/locales folder
#
load_path = Dir[File.join(Rails.root, 'config', 'locales', '**', '*.{rb,yml}')]

#
# trim load_path #1:
#
#   select only locales enabled in crabgrass conf
#   (if there are any configured)
#
if Conf.enabled_languages.any?
  load_path = load_path.select do |path|
    Conf.enabled_languages.detect do |enabled_lang_code|
      path.include?('/en/') or path.include?("#{enabled_lang_code}.yml")
    end
  end
end

#
# trim load_path #2
#
#   for English only load files from locales/en/*.yml, not en.yml.
#   en.yml is only needed for transiflex
#   (rake cg:i18n:bundle to generate en.yml)
#
load_path = load_path.reject do |path|
  path.include?('en.yml')
end

#
# put override paths last
#
Dir[File.join(LOCALE_OVERRIDE_DIRECTORY, '**', '*.yml')].each do |path|
  load_path << path
end

#
# set the load paths
#
I18n.load_path << load_path
I18n.default_locale = Conf.default_language
I18n.exception_handler = :crabgrass_i18n_exception_handler

I18n.load_path.flatten!

# let's enable the use of cascade
I18n::Backend::Simple.send(:include, I18n::Backend::Cascade)

#
# Turn off reloading of .yml files after every request if in BOOST mode.
# Makes everything much much faster!!
#
if ENV['BOOST']
  module SkipReloading
    def skip_reload!; end

    def self.included(backend)
      backend.class_eval do
        alias_method :reload_for_real!, :reload!
        alias_method :reload!, :skip_reload!
      end
    end
  end
  I18n::Backend::Simple.send(:include, SkipReloading)
end
