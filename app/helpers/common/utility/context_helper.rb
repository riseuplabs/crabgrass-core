module Common::Utility::ContextHelper

  # we only show the context if you either:
  # * are allowed to do what you are doing
  # * can see the context entity anyway (for error messages)
  def visible_context?
    @context &&
      ( @authorized || current_user.may?(:view, @context.entity) )
  end

  #
  # sets up the navigation variables from the current theme.
  #
  # The 'active' blocks of the navigation definition are evaluated in this
  # method, so any variables needed by those blocks must be set up before this
  # is called.
  #
  def current_navigation
    @navigation ||= begin
      navigation = {}
      navigation[:global] = current_theme.navigation.root
      if navigation[:global]
        navigation[:context] = navigation[:global].currently_active_item
        if navigation[:context]
          navigation[:local] = navigation[:context].currently_active_item
        end
      end
      navigation = setup_navigation(navigation) # allow controller change to modify @navigation
      navigation
    end
  end

  ##
  ## TITLE
  ##

  def context_titles
    return [] unless @context
    @context.breadcrumbs.collect do |i|
      truncate( crumb_to_s(i) )
    end.reverse
  end

  def context_class
    @context.breadcrumbs.first if visible_context?
  end

  ##
  ## BANNER
  ##

  def context_banner_style
    @context_banner_style ||= if banner_picture
      if banner_picture.add_geometry(banner_geometry)
        url = banner_picture.url(banner_geometry)
        if banner_picture.average_color
          bg = rgb_to_hex(banner_picture.average_color)
          fg = contrasting_color(banner_picture.average_color)
          if fg == '#fff'
            shadow = '#000'
            nav_shade = 'rgba(0,0,0,0.2)'
          else
            shadow = '#fff'
            nav_shade = 'rgba(255,255,255,0.3)'
          end
          "#banner_content {background-image: url(#{url}); background-color: #{bg}}\n"+
          "#banner_content a.title {color: #{fg}; text-shadow: #{shadow} 1px 1px 1px}\n"+
          "ul#banner_nav_ul li.tab a.tab {color: #{fg}; background-color: #{nav_shade}}"
        else
          "#banner_content {background-image: url(#{url})}"
        end
      end
    end
  end

  def context_picture_url(geometry)
    if banner_picture
      banner_picture.add_geometry(geometry)
      picture.url(geometry)
    end
  end

  #
  # we used to do fancy things to calculate this, but now we just hard code the geometry and
  # let the css expand or shrink the banner as needed.
  #
  def banner_geometry
    {max_width: banner_width, min_width: banner_width, max_height: banner_height, min_height: banner_height}
  end

  def banner_width
    current_theme['banner_width'].to_i
  end

  def banner_height
    current_theme['banner_height'].to_i
  end

  def banner_picture
    @banner_picture ||= @context && @context.entity.profiles.public.picture
  end

  ##
  ## DETECTION
  ##

  #
  # returns true if the current display context matches the symbol.
  # options are :none, :me, :group, or :user
  #
  def context?(symbol)
    case symbol
      when :none  then @context.nil?
      when :me    then @context.is_a?(Context::Me)
      when :group then @context.is_a?(Context::Group)
      when :user  then @context.is_a?(Context::User)
    end
  end

  private

  #
  # e.g. [255, 0, 0] => '#ff0000'
  #
  def rgb_to_hex(rgb)
    '#' + rgb.map{|color|"%02x"%color}.join
  end

  #
  # https://gamedev.stackexchange.com/questions/38536/given-a-rgb-color-x-how-to-find-the-most-contrasting-color-y/38542#38542
  # Luminance calculation here is an approximation because RGB is not converted to linear sRGB.
  #
  def contrasting_color(rgb)
    gamma = 2.2
    red, green, blue = rgb[0]/255.0, rgb[1]/255.0, rgb[2]/255.0
    luminance = (0.2126*(red**gamma)) + (0.7152*(green**gamma)) + (0.0722*(blue**gamma))
    if luminance >= 0.5
      '#000'
    else
      '#fff'
    end
  end

  def crumb_to_s(crumb)
    if crumb.is_a? Array
      crumb[0].to_s
    elsif crumb.respond_to? :display_name
      crumb.display_name
    else
      crumb.to_s
    end
  end

end
