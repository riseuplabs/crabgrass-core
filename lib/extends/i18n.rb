# encoding: utf-8

class Symbol
  def t(options = {})
    I18n.t(self, options)
  end

  # translates a string, but capitalizes the first letter of the result.
  #
  # this differs from String.capitalize (which lowers subsequent characters),
  # and from String.titlecase (which makes the first letter of each word
  # a capital letter).
  #
  def tcap(options = {})
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

module I18nWithException

  def translate(*args)
    super(*args)
    rescue ArgumentError => exception
     # MissingTranlationData is already handled in translate.
     # If it shows up here the handler already reraised and so do we.
    raise if exception.is_a? I18n::MissingTranslationData
      options  = args.last.is_a?(Hash) ? args.pop.dup : {}
      key      = args.shift
      locale   = options.delete(:locale) || config.locale
      handling = options.delete(:throw) && :throw || options.delete(:raise) && :raise
      handle_exception(handling, exception, locale, key, options)
   end
end

I18n.singleton_class.prepend I18nWithException

module I18n
  Lang = Struct.new('Lang', :name, :code, :order, :rtl)

  class << self
    def languages
      @languages ||= begin
        # sorted here alphabetically.
        # order attribute is roughly according to
        # https://en.wikipedia.org/wiki/List_of_languages_by_number_of_native_speakers
        hsh = HashWithIndifferentAccess.new(Lang.new('Unknown', :xx, false))
        hsh[:ar] = Lang.new('العربية',   'ar',  5, true)
        hsh[:bg] = Lang.new('български език', 'bg', 18, false)
        hsh[:ca] = Lang.new('Català',    'ca', 19, false)
        hsh[:cs] = Lang.new('Čeština',   'cs', 100, false)
        hsh[:de] = Lang.new('Deutsch',   'de',  8, false)
        hsh[:el] = Lang.new('Ελληνικά',  'el', 15, false)
        hsh[:en] = Lang.new('English',   'en',  3, false)
        hsh[:es] = Lang.new('Español',   'es',  2, false)
        hsh[:eu] = Lang.new('Euskara',   'eu', 101, false)
        hsh[:fa] = Lang.new('فارسی',  'fa', 25, true)
        hsh[:fr] = Lang.new('Français',  'fr',  9, false)
        hsh[:he] = Lang.new('עִבְרִית',     'he', 17, true)
        hsh[:hu] = Lang.new('magyar nyelv',     'hu', 78, true)
        hsh[:it] = Lang.new('Italiano',  'it', 11, false)
        hsh[:nl] = Lang.new('Nederlands', 'nl', 14, false)
        hsh[:no] = Lang.new('Norsk',     'no', 21, false)
        hsh[:pl] = Lang.new('Polski',    'pl', 12, false)
        hsh[:pt] = Lang.new('Português', 'pt',  6, false)
        hsh[:ru] = Lang.new('Pyccĸий',   'ru',  7, false)
        hsh[:sv] = Lang.new('Svenska',   'sv', 16, false)
        hsh[:tr] = Lang.new('Türkçe',    'tr', 10, false)
        hsh
      end
    end

    def sorted_languages
      @sorted_languages ||= languages.values.sort_by(&:order)
    end

    # def language_for_locale(locale)
    #  load_available_languages if @languages.blank?
    #  languages[locale.to_sym]
    # end

    # def available_languages
    #  load_available_languages if @languages.blank?
    #  @languages.values.compact.sort_by(&:id)
    # end

    protected

    # def load_available_languages
    #  #  @languages = {
    #  #   :en => #<Language code:"en" ...>,
    #  #   :es => #<Language code:"es" ..>
    #  #  }
    #
    #  @languages = {}
    #  I18n.available_locales.each do |code|
    #    @languages[code] = Language.find_by_code(code.to_s)
    #  end
    # end
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
  raise exception if !Rails.env.production? && Conf.raise_i18n_exceptions

  # use the humanized version of the key as a fallback
  key.to_s.humanize
end
