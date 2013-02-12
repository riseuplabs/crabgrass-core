module Groups::SettingsHelper

  def group_settings_form
    formy(:table_form) do |f|

      f.heading :display.t
      f.row do |r|
        r.label :name.t
        r.input text_field('group', 'name', :size => 40, :maxlength => 40)
        r.info "(#{:required.t}) "
        r.info :link_name_description.t
      end

      f.row do |r|
        r.label :display_name.t
        r.label_for 'group_full_name'
        r.input text_field('group', 'full_name', :size => 40, :maxlength => 100)
        r.info "(#{:optional.t}) "
        r.info I18n.t(:descriptive_name_for_display)
      end

      f.row do |r|
        r.label :icon.t
        r.input avatar_field(@group.becomes Group)
      end

      f.heading :locale.t
      f.row do |r|
        r.label :language.t
        r.label_for 'group_language'
        r.input select('group', 'language', all_languages_for_select, { :include_blank => true })
      end

      f.buttons submit_tag(:save_button.t, :class => 'btn btn-primary')

    end
  end

end
