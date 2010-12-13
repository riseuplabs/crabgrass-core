class Symbol
  def t(options={})
    I18n.t(self,options)
  end
  def tcap(options={})
    result = I18n.t(self, options).mb_chars
    result[0..0].upcase + result[1..-1]
  end
end

class String
  # When called on a string t() returns self. One advantage of this, is you
  # can call t() on anything you are about to display, and if it is a symbol
  # it gets localized, but if it is a string then no harm done.
  def t(options={})
    self
  end

  # 
  # translates a string, but capitalizes the first letter of the result.
  # 
  # this differs from String.capitalize (which lowers subsequent characters),
  # and from String.titlecase (which makes the first letter of each word
  # a capital letter).
  # 
  def tcap(options={})
    self
    #result = I18n.t(self, options).mb_chars # get multibyte proxy
    #result[0..0].upcase + result[1..-1]
  end
end

module I18n
  class << self
    def language_for_locale(locale)
      load_available_languages if @languages.blank?
      @languages[locale.to_sym]
    end

    def available_languages
      load_available_languages if @languages.blank?
      @languages.values.compact.sort_by(&:id)
    end

    def site_scope
      scope_name = Site.current.try.name.try.to_sym
      # default is reserved word
      scope_name == :default ? nil : scope_name
    end

    def translate_with_site_scope(key, options = {})
      if site_scope
        site_options = options.dup
        site_options[:scope] = [site_scope] | (options[:scope] || [])

        site_specific_translation = translate_without_site_scope(key, site_options)
      end
    ensure
      return site_specific_translation unless site_specific_translation.blank?
      return translate_without_site_scope(key, options)
    end

    alias_method_chain :translate, :site_scope
    alias_method :t, :translate_with_site_scope

    protected

    def load_available_languages
      #  @languages = {
      #   :en => #<Language code:"en" ...>,
      #   :es => #<Language code:"es" ..>
      #  }

      @languages = {}
      I18n.available_locales.each do |code|
        @languages[code] = Language.find_by_code(code.to_s)
      end
    end
  end
end


def crabgrass_i18n_exception_handler(exception, locale, key, options)
  # see i18n.rb in activesupport gem
  # for the default I18n exception_handler
  if I18n::MissingTranslationData === exception
    #options[:scope] ||= []
    # try falling back to non-site specific translations
    #keys = I18n.send(:normalize_translation_keys, locale, key, options[:scope])
    if I18n.site_scope && options[:scope].try.first == I18n.site_scope
      # do nothing, site scope is alway used optionaly.
      return nil
    elsif locale == :en
      if RAILS_ENV != "production" && (RAILS_ENV == 'test' ? Conf.raise_i18n_exceptions : true )
        raise exception
      else
        return key.to_s.humanize
      end
    else
      options[:locale] = :en
      return I18n.translate(key, options)
    end
  end

  raise exception
end
