module Common::Utility::ContextHelper
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

  ##
  ## BANNER
  ##

  def context_banner_style
    if picture = @context.entity.profiles.public.picture
      banner_height = current_theme.int_var(:banner_padding) * 2 + current_theme.int_var(:icon_large) + 4
      geometry = {:max_width => banner_width, :min_width => banner_width, :max_height => banner_height, :min_height => banner_height}
      picture.add_geometry!(geometry)
      "background-image: url(#{picture.url(geometry)})"
    else
      ""
    end
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
