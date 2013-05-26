
module Common::Ui::TextHelper

  protected

  #
  # simply makes a string bold. for use with i18n,
  # like :created_by_user.t(:user => bold(user.name))
  #
  def bold(str)
    "<b>#{h(str)}</b>".html_safe
  end

  # convert greencloth marktup to html
  def to_html(str)
    ## FIXME: add 'html_safe' in GreenCloth's to_html instead of here
    str.present? ? GreenCloth.new(str).to_html().html_safe : ''
  end

  def header_with_more(tag, klass, text, more_url=nil)
    span = more_url ? " " + content_tag(:span, "&bull; " + link_to((I18n.t(:see_more_link)+ARROW).html_safe, more_url)) : ""
    content_tag tag, text + span, :class => klass
  end

  # where is this used? what does it do? not sure where to put it?
  # show link with totals for a collection that belongs to an object
  def totalize_with_link(object, collection, controller=nil, action=nil)
    action ||= 'list'
    controller ||= url_for(:controller => object.class.name.pluralize.underscore, :action => action)
    link_if_may(I18n.t(:total, :count => (collection.size).to_s) ,
                   controller , action, object) or
    I18n.t(:total, :count => (collection.size).to_s)
  end

  #
  # Text with a more link
  #
  # :options[:url] = the url for more link
  # :options[:length] = the max lenght to display
  #
  def text_with_more(text,  options={})
    length = options[:length] || 50
    omission = options[:omission] || "... "
    if options[:url]
      link = link_to((' '+I18n.t(:see_more_link)+ARROW).html_safe, options[:url])
    else
      link = ''
    end
    truncate(text, :length => length, :omission => omission + link)
  end

#  def linked_activity_description(activity)
#    description = activity.try.safe_description(self)
#    expand_links(description)
#  end

#  def display_activity(activity)
#    description = activity.try.safe_description(self)
#    return unless description

#    description = expand_links(description)

#    created_at = (friendly_date(activity.created_at) if activity.created_at)

#    more_link = activity.link
#    if more_link.is_a? Hash
#      more_link = link_to(I18n.t(:details_link) + ARROW, more_link, :class => 'shy')
#    end
#    more_link = content_tag(:span, [created_at, more_link].combine, :class => 'commands')

#    css_class = "small_icon #{activity.icon}_16 shy_parent"
#    css_style = activity.style

#    content_tag :li, [description, more_link].combine, :class => css_class, :style => css_style
#  end


  # *NEWUI
  #
  # returns the kind of profile open or closed/private
  #
#  def open_or_private(profile)
#    if profile.may_see?
#      t(:open)
#    else
#      t(:private)
#    end
#  end


end
