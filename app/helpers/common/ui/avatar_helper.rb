module Common::Ui::AvatarHelper

  #
  # deprecated: i don't like <img> tags
  #
  def avatar_link(viewable, size='medium')
    if viewable
      link_to avatar_for(viewable, size), entity_path(viewable)
    end
  end

  #
  # deprecated: i don't like <img> tags
  #
  def avatar_for(viewable, size='medium', options={})
    return nil if viewable.blank? || viewable.new_record?
    image_tag(
      avatar_url_for(viewable, size),
      {:size => Avatar.pixels(size),
      :class => (options[:class] || "avatar avatar_#{size}")}.merge(options)
    )
  end

  ## returns the url for the user's or group's avatar
  def avatar_url_for(viewable, size='medium')
    if viewable
      '/avatars/%s/%s.jpg?%s' % [viewable.avatar_id||0, size, viewable.updated_at.to_i]
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

