module ProfileHelper

  def banner_field(formy)
    formy.heading :banner.t

    if @profile.picture
      formy.row do |r|
        r.input clear_banner_input
      end
    else
      formy.row do |r|
        r.label I18n.t(:file)
        r.label_for 'profile_picture_upload'
        r.input file_field_tag('profile[picture][upload]',
                               :id => 'profile_picture_upload')
        r.info :banner_info.t
      end
    end
  end

  def clear_banner_input
    [ picture_tag(@profile.picture, :medium),
      submit_tag("Clear", :name => 'clear_photo')
    ].join '<br/>'
  end
end

