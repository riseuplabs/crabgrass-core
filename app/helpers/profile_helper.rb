module ProfileHelper

  def banner_field(formy)
    formy.heading :banner.t

    if @profile.picture
      formy.row(class: :current_banner) do |r|
        r.input picture_tag(@profile.picture, :medium)
      end
    end
    formy.row do |r|
      r.label I18n.t(:file)
      r.label_for 'profile_picture_upload'
      r.input file_field_tag('profile[picture][upload]',
                             id: 'profile_picture_upload')
      r.info :banner_info.t(
        optimal_dimensions: "#{banner_width.to_i} x #{banner_height.to_i}"
      )
    end
  end

end

