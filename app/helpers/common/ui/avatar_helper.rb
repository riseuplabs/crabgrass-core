module Common::Ui::AvatarHelper

  # is this used anywhere?
  def avatar_link(viewable, size='medium')
    if viewable
      link_to avatar_for(viewable, size), entity_path(viewable)
    end
  end

  #
  # creates an IMG tag for the avatar.
  #
  # I prefer background images for most stuff, but this can be useful at times.
  #
  def avatar_for(viewable, size='medium', options={})
    return nil if viewable.blank? || viewable.new_record?
    image_tag(
      avatar_url_for(viewable, size),
      {:size => Avatar.pixels(size),
      :class => (options[:class] || "avatar avatar_#{size}")}.merge(options)
    )
  end

  #
  # Returns the url for the user's or group's avatar.
  #
  # All avatars should be shown using this method. Significantly,
  # we do not need to query the avatar object in order to show the avatar,
  # and we key the URL on the version of the viewable (ie user or group).
  # This will keep most browsers from caching the avatar when it changes.
  # 
  def avatar_url_for(viewable, size='medium')
    if viewable
      '/avatars/%s/%s.jpg?%s' % [viewable.avatar_id||0, size, viewable.version]
    else
      '/avatars/0/%s.jpg' % size
    end
  end

  def avatar_style(viewable, size='medium')
    "background-image: url(%s)" % avatar_url_for(viewable, size)
  end

  def square_avatar_style(viewable, size='medium')
    "background-image: url(%s); width: %spx; height: %spx;" % [
      avatar_url_for(viewable, size), Avatar.pixel_width(size), Avatar.pixel_width(size)
    ]
  end

end

