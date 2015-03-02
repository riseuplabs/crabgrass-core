# encoding: utf-8

class Symbol
  def t(options={})
    I18n.t(self,options)
  end

  # translates a string, but capitalizes the first letter of the result.
  #
  # this differs from String.capitalize (which lowers subsequent characters),
  # and from String.titlecase (which makes the first letter of each word
  # a capital letter).
  #
  def tcap(options={})
    result = I18n.t(self, options).mb_chars
    result[0..0].upcase + result[1..-1]
  end
end

class String
  # When called on a string t() returns self. One advantage of this, is you
  # can call t() on anything you are about to display, and if it is a symbol
  # it gets localized, but if it is a string then no harm done.
  def t
    self
  end

  def tcap
    self
  end
end

module I18n

  Lang = Struct.new("Lang", :name, :code, :order, :rtl)

  class << self
    def languages
      @languages ||= begin
        hsh = HashWithIndifferentAccess.new(Lang.new('Unknown', :xx, false))
        # In order of number of speakers worldwide
        # http://en.wikipedia.org/wiki/Most_spoken_languages
        hsh[:zh] = Lang.new('中文',      'zh',  1, false)
        hsh[:es] = Lang.new('Español',   'es',  2, false)
        hsh[:en] = Lang.new('English',   'en',  3, false)
        hsh[:hi] = Lang.new('हिन्दी',     'hi',  4, false)
        hsh[:ar] = Lang.new('العربية',   'ar',  5, true)
        hsh[:pt] = Lang.new('Português', 'pt',  6, false)
        hsh[:ru] = Lang.new('Pyccĸий',   'ru',  7, false)
        hsh[:de] = Lang.new('Deutsch',   'de',  8, false)
        hsh[:fr] = Lang.new('Français',  'fr',  9, false)
        hsh[:tr] = Lang.new('Türkçe',    'tr', 10, false)
        hsh[:it] = Lang.new('Italiano',  'it', 11, false)
        hsh[:pl] = Lang.new('Polski',    'pl', 12, false)
        hsh[:sw] = Lang.new('Kiswahili', 'sw', 13, false)
        hsh[:nl] = Lang.new('Nederlands','nl', 14, false)
        hsh[:el] = Lang.new('Ελληνικά',  'el', 15, false)
        hsh[:sv] = Lang.new('Svenska',   'sv', 16, false)
        hsh[:he] = Lang.new('עִבְרִית',     'he', 17, true)
        hsh[:bg] = Lang.new('български език', 'bg', 18, false)
        hsh[:ca] = Lang.new('Català',    'ca', 19, false)
        hsh[:da] = Lang.new('Dansk',     'da', 20, false)
        hsh[:no] = Lang.new('Norsk',     'no', 21, false)
        hsh
      end
    end

    def sorted_languages
      @sorted_languages ||= languages.values.sort do |a, b|
        a.order <=> b.order
      end
    end

    #def language_for_locale(locale)
    #  load_available_languages if @languages.blank?
    #  languages[locale.to_sym]
    #end

    #def available_languages
    #  load_available_languages if @languages.blank?
    #  @languages.values.compact.sort_by(&:id)
    #end

    def site_scope
      scope_name = Site.current.try.name.try.to_sym
      # default is reserved word
      scope_name == :default ? nil : scope_name
    end

    def scope_on_site(scope)
      case scope
      when Array
        scope.dup.unshift(site_scope)
      when nil
        [site_scope]
      else
        [site_scope, scope]
      end
    end
    private :scope_on_site

    #
    # We allow site specific translations.
    #
    # just create a scope for the site in your locales and put them there.
    #
    # If a site_scope is set translations are looked up like this:
    # * site specific translation for current locale
    # * translation for current locale
    # * :default option specified
    # * site specific english translation
    # * english translation

    def translate_with_site_scope(*args)
      key = args.first
      options = args[1] || {}
      if site_scope
        site_options = options.dup
        site_options.delete(:default)
        site_options[:scope] = scope_on_site(options[:scope])
        site_specific_translation = translate_without_site_scope(key, site_options)
      end
    ensure
      return site_specific_translation if site_specific_translation.present?
      return translate_without_site_scope(*args)
    end

    def translate_with_exception_handler(*args)
      translate_without_exception_handler(*args)
    rescue ArgumentError => exception
      # MissingTranlationData is already handled in translate.
      # If it shows up here the handler already reraised and so do we.
      raise if exception.is_a? MissingTranslationData
      options  = args.last.is_a?(Hash) ? args.pop.dup : {}
      key      = args.shift
      locale   = options.delete(:locale) || config.locale
      handling = options.delete(:throw) && :throw || options.delete(:raise) && :raise 
      handle_exception(handling, exception, locale, key, options)
    end

    alias_method_chain :translate, :site_scope
    alias_method_chain :translate, :exception_handler

    # this alias will include both chains
    alias_method :t, :translate_with_exception_handler

    protected

    #def load_available_languages
    #  #  @languages = {
    #  #   :en => #<Language code:"en" ...>,
    #  #   :es => #<Language code:"es" ..>
    #  #  }
    #
    #  @languages = {}
    #  I18n.available_locales.each do |code|
    #    @languages[code] = Language.find_by_code(code.to_s)
    #  end
    #end
  end
end

#
# This is called whenever there is a i18n problem.
#
# see i18n.rb in activesupport gem
# for the default I18n exception_handler
#
def crabgrass_i18n_exception_handler(exception, locale, key, options)
  exception = exception.to_exception if exception.respond_to? :to_exception
  raise exception unless exception.is_a? I18n::ArgumentError

  # site scope is optional, so let's try without it.
  if I18n.site_scope && options[:scope].try.first == I18n.site_scope
    return nil
  end

  # log issues other than just a missing translation
  unless exception.is_a? I18n::MissingTranslationData
    Rails.logger.error exception
  end

  # fall back to english version of the key
  if locale != :en
    options[:locale] = :en
    return I18n.translate(key, options)
  end

  # raise exceptions when running in development mode
  if !Rails.env.production? && Conf.raise_i18n_exceptions
    raise exception
  end
 
  # use the humanized version of the key as a fallback
  key.to_s.humanize
end
