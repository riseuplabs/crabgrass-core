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
  #def link_to_user_avatar(arg, options={})
  #  login, path, display_name = login_and_path_for_user(arg,options)
  #  return "" if login.blank?
  #
  #  style = options[:style] || ""                   # allow style override
  #  label = options[:login] ? login : display_name  # use display_name for label by default
  #  label = options[:label] || label                # allow label override
  #  klass = options[:class] || 'icon'
  #  options[:title] ||= display_name
  #  options[:alt] ||= display_name
  #
  #  avatar = link_to(avatar_for(arg, options[:avatar], options), path,:class => klass, :style => style)
  #end

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

  #
  # Display a group or user, with or without a link.
  # All such displays should be made by this method.
  #
  # options:
  #
  #   :avatar => nil | :tiny | :xsmall | :small | :medium | :large | :xlarge (default: nil)
  #
  #   :format => :short (entity.name)
  #              :full  (entity.display_name)
  #              :both  (both name and display name)
  #              :two   (both name and display name on two lines)
  #              (default: full)
  #
  #   to create a link, specify one of one of:
  #     (1) :url      => creates a normal link_to
  #     (2) :remote   => creates a link_to_remote
  #     (3) :function => creates a link_to_function
  #
  #   :class => added to the elements's class
  #   :style => added to the element's style
  #
  def display_entity(entity, options={})

    format   = options[:format] || :full
    styles   = [options[:style]]
    classes  = [options[:class], 'entity']

    # avatar

    if options[:avatar]
      classes << options[:avatar]
      classes << 'icon'
      styles  << avatar_style(entity, options[:avatar])
    end

    # label 

    display, title = if entity.nil?
      [:unknown.t, nil]
    elsif format == :short
      classes << 'single'
      [entity.name, h(entity.display_name)]
    elsif format == :full
      classes << 'single'
      [h(entity.display_name), entity.name]
    elsif format == :both
      classes << 'single'
      [h(entity.both_names), nil]
    elsif format == :two
      if entity.name != entity.display_name
        ["#{entity.name}<br/>#{h(entity.display_name)}", nil]
      else
        classes << 'single'
        [entity.name, nil]
      end
    end

    # element

    element_options = {:class => classes.join(' '), :style => styles.join(';'), :title => title}
    if options[:remote]
      link_to_remote(display, options[:remote], element_options)
    elsif options[:function]
      link_to_function(display, options[:function], element_options)
    elsif options[:url]
      link_to(display, options[:url], element_options)
    else
      content_tag(:div, display, element_options)
    end
  end

  #
  # used when generating json to return for autocomplete popups
  #
  def entity_autocomplete_line(entity)
    "<em>%s</em>%s" % [entity.name, ('<br/>' + h(entity.display_name) if entity.display_name != entity.name)]
  end
   
end
