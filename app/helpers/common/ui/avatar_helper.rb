module Common::Ui::AvatarHelper

  #
  # creates an avatar that links to the entity, but with no text.
  #
  def avatar_link(entity, size='medium')
    if entity
      link_to avatar_for(entity, size), entity_path(entity), {title: entity.display_name }
    end
  end

  #
  # creates an IMG tag for the avatar.
  #
  # I prefer background images for most stuff, but this can be useful at times.
  #
  def avatar_for(entity, size='medium', options={})
    return nil if entity.blank? || entity.new_record?
    image_tag(
      avatar_url_for(entity, size),
      {size: Avatar.pixels(size),
      class: (options[:class] || "avatar avatar_#{size}")}.merge(options)
    )
  end

  #
  # Returns the url for the user's or group's avatar.
  #
  # All avatars should be shown using this method. Significantly,
  # we do not need to query the avatar object in order to show the avatar,
  # and we key the URL on the version of the entity (ie user or group).
  # This will keep most browsers from caching the avatar when it changes.
  #
  def avatar_url_for(entity, size='medium')
    if entity
      '/avatars/%s/%s.jpg?%s' % [entity.avatar_id||0, size,
        entity.respond_to?(:version) ? entity.version : entity.updated_at.to_i]
    else
      '/avatars/0/%s.jpg' % size
    end
  end

  def avatar_style(entity, size='medium')
    "background-image: url(%s)" % avatar_url_for(entity, size)
  end

  def square_avatar_style(entity, size='medium')
    "background-image: url(%s); width: %spx; height: %spx;" % [
      avatar_url_for(entity, size),
      avatar_height(size),
      avatar_height(size)
    ]
  end

  # full height/width of avatar + avatar-border in banner
  def avatar_height(size='medium')
    Avatar.pixel_width(size) + (current_theme.banner_avatar_border.to_i * 2)
  end

  def avatar_field(entity)
    avatar_for(entity, 'large') + "&nbsp;".html_safe +
      upload_avatar_link(entity)
  end

  def upload_avatar_link(entity)
    link_to_modal :upload_image_link.t,
      { url: edit_avatar_path(entity), icon: 'picture_edit' },
      { class: 'inline' }
  end

  def remove_image_link(entity)
    link_to :remove_image_link.t, me_avatar_path(entity), method: :delete,
      icon: 'trash', class: 'inline', confirm: :confirm_image_delete.t
  end

  def edit_avatar_path(entity)
    if entity == current_user
      edit_me_avatar_path
    else
      edit_group_avatar_path(entity)
    end
  end
end

