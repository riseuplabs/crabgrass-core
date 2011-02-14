#
# generate links and display of users and groups
#

module Common::Ui::EntityDisplayHelper

  protected

  # linking to users and groups takes a lot of time if we have to fetch the
  # record to get the display name or avatar. if we already have the login or
  # group name, this method is much faster (saves about 150ms per request). 
  def link_to_name(name)
    "<a href=\"/#{name}\">#{name}</a>"
  end

  #
  # provides placeholder for when the user or group record has been destroyed.
  #
  def link_to_unknown(options)
    styles  = [options[:style]]
    classes = [options[:class]]
    if options[:avatar]
      classes << options[:avatar]
      classes << 'icon'
      styles  << avatar_style(nil, options[:avatar])
    end
    content_tag :span, :unknown.t, :class => classes.join(' '), :style => styles.join(';')
  end

  ##
  ## GROUPS
  ##

  # 
  #
  # options:
  #
  #  :avatar => [:small | :medium | :large]
  #  :style  => added to <a> tag
  #  :class  => added to <a> tag
  #  
  def link_to_group(group, options={})
    return link_to_unknown(options) if group.nil?

    url          = url_for_group(group)
    display_name = group.display_name
    styles       = [options[:style]]
    classes      = [options[:class]]
    if options[:avatar]
      classes << options[:avatar]
      classes << 'icon'
      styles  << avatar_style(group, options[:avatar])
    end
    link_to(display_name, url, :class => classes.join(' '), :style => styles.join(';'))
  end


  ##
  ## USERS
  ##

  #
  # creates a link to a user, with or without the avatar.
  #
  # accepts:
  #
  #  :avatar => [:small | :medium | :large]
  #  :style -- add additional styles
  #  :class -- add additional classes
  #
  def link_to_user(user, options={})
    return link_to_unknown(options) if user.nil?

    styles  = [options[:style]]
    classes = [options[:class]]
    path    = user.path
   
    label   = user.display_name    
    if label.length > 19
      options[:title] = label
      label = truncate(label, :length => 19)
    end

    if options[:avatar]
      classes << options[:avatar]
      classes << 'icon'
      url = avatar_url_for(user, options[:avatar])
      styles << "background-image:url(#{url})"
    end
    link_to(label, path, :class => classes.join(' '), :style => styles.join(';'), :title => options[:title])
  end

  # creates a link to a user, with or without the avatar.
  # avatars are displayed as background images, with padding
  # set on the <a> tag to make room for the image.
  # accepts:
  #  :avatar => [:small | :medium | :large]
  #  :label -- override display_name as the link text
  #  :style -- override the default style
  #  :class -- override the default class of the link (icon)
  #
  def link_to_user_avatar(arg, options={})
    login, path, display_name = login_and_path_for_user(arg,options)
    return "" if login.blank?

    style = options[:style] || ""                   # allow style override
    label = options[:login] ? login : display_name  # use display_name for label by default
    label = options[:label] || label                # allow label override
    klass = options[:class] || 'icon'
    options[:title] ||= display_name
    options[:alt] ||= display_name

    avatar = link_to(avatar_for(arg, options[:avatar], options), path,:class => klass, :style => style)
  end

  ##
  ## GENERIC PERSON OR GROUP
  ##

  def link_to_entity(entity, options={})
    if entity.is_a? User
      link_to_user(entity, options)
    elsif entity.is_a? Group
      link_to_group(entity, options)
    end
  end

  # Display a group or user, without a link. All such displays should be made by
  # this method.
  #
  # options:
  #   :avatar => nil | :xsmall | :small | :medium | :large | :xlarge (default: nil)
  #   :format => :short | :full | :both | :hover | :twolines (default: full)
  #   :link => nil | true | url (default: nil)
  #   :class => passed through to the tag as html class attr
  #   :style => passed through to the tag as html style attr
  #   :tag   => the html tag to use for this display (ie :div, :span, :li, :a, etc)
  #
  def display_entity(entity, options={})
    format  = options[:format] || :full
    display = nil
    hover   = nil
    classes = [options[:class], 'entity']
    styles  = [options[:style]]
    link    = options[:link] || options[:tag] == :a

    name = entity.name
    display_name = h(entity.display_name)
    both_names = h(entity.both_names)
    if link
      url = link === true ? url_for_entity(entity) : link
      if options[:tag] == :a
        href = url
      else
        name         = link_to(name, url)
        display_name = link_to(display_name, url)
        both_name    = link_to(both_names, url)
        href = nil
      end
    end

    if options[:avatar]
      url = avatar_url_for(entity, options[:avatar])
      classes << "icon"
      classes << options[:avatar]
      styles << "background-image:url(#{url})"
    end
    display, title, hover = case options[:format]
      when :short then [name,         display_name, nil]
      when :full  then [display_name, name,         nil]
      when :both  then [both_names,   nil,          nil]
      when :hover then [name,         nil,          display_name]
      when :twolines then ["<div class='name'>%s</div>%s"%[name, (display_name if name != display_name)], nil, nil]
    end
    #if hover
    #  display += content_tag(:b,hover)
    #  options[:style] = [options[:style], "position:relative"].compact.join(';')
    #  # ^^ to allow absolute popup with respect to the name
    #end
    if options[:format] == :twolines and name != display_name
      classes << 'two'
    end
    element = options[:tag] || :div
    content_tag(element, display, :style => styles.join(';'), :class => classes.join(' '), :title => title, :href => href)
  end

  #
  # used when generating json to return for autocomplete popups
  #
  def entity_autocomplete_line(entity)
    "<em>%s</em>%s" % [entity.name, ('<br/>' + h(entity.display_name) if entity.display_name != entity.name)]
  end
   
end
