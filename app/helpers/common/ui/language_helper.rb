module Common::Ui::LanguageHelper

  def language_select_tag
    unless @language_form_already_rendered
      @language_form_already_rendered = true
      content_tag :form, :method => 'post', :action => language_path, :style => 'display: inline' do
        content_tag('input', '', :type => 'hidden', :name => "authenticity_token", :value => form_authenticity_token) +
        select_tag('id', options_for_language, :onchange => 'this.form.submit();', :id => nil)
      end
    end
  end

  def options_for_language(selected=nil)
    selected ||= session[:language_code].to_s
    options_array = Conf.enabled_languages.collect do |locale|
      [I18n.languages[locale].name, locale.to_s]
    end
    options_for_select(options_array, selected)
  end

  def all_languages_for_select
    I18n.sorted_languages.collect do |lang|
      [lang.name, lang.code]
    end
  end

  def language_direction
    @language_direction ||= if I18n.languages[session[:language_code]].rtl
      "rtl"
    else
      "ltr"
    end
  end

end

