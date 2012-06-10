module Me::SettingsHelper

  def my_settings_form
    formy(:table_form) do |f|

      f.heading :display.t
      f.row do |r|
        r.label :username.t
        r.input text_field('user','login')
      end

      f.row do |r|
        r.label :display_name.t
        r.input text_field('user','display_name')
      end

      f.row do |r|
        r.label :icon.t
        r.input avatar_field(current_user)
      end

      f.heading :notification.t
      f.row do |r|
        r.label :email.t
        r.input text_field('user','email')
      end

      ## TODO I18N:
      f.row do |r|
        r.label :notice.t
        r.info :do_you_want_to_receive_email_notifications.t
        r.input select('user', 'receive_notifications', [["No", ""], ["Yes: an email per change","Single"], ["Yes: just a summary email","Digest"]])
      end

      f.heading :locale.t
      f.row do |r|
        r.label :language.t
        r.input select('user', 'language', all_languages_for_select, { :include_blank => true })
      end

      f.row do |r|
        r.label :time_zone.t
        r.input time_zone_select('user', 'time_zone', nil, :include_blank => true)
      end

      f.buttons submit_tag(:save_button.t, :class => 'btn btn-primary')
    end
  end

end
