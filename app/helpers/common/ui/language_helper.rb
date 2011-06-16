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

  def language_select_links
    @language_form_already_rendered = true
    enabled_language_array.collect do |lang_name, lang_code|
      #active = lang_code == session[:language_code].to_s ? 'hilight' : ''
      if lang_code == session[:language_code].to_s
        link_to_with_icon('ok', lang_name, language_path(:id => lang_code), :method => 'post', :class => 'inline', :style => 'margin-right: 1em; line-height: 2em')
      else
        link_to(lang_name, language_path(:id => lang_code), :method => 'post', :style => 'margin-right: 1em; line-height: 2em')
      end
    end.join(' ')
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

  private

  def enabled_language_array
    Conf.enabled_languages.collect do |locale|
      [I18n.languages[locale].name, locale.to_s]
    end
  end

  def options_for_language(selected=nil)
    selected ||= session[:language_code].to_s
    options_for_select(enabled_language_array, selected)
  end

end

