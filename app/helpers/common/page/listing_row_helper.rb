#
# a helper for page lists in the 'detailed' view.
#

module Common::Page::ListingRowHelper

  protected

  #
  # helper to show stars of an item (page or whatever that responds to stars_count)
  #
#  def stars_for(item)
#    if item.stars_count > 0
#      content_tag(:span, "%s %s" % [icon_tag('star'), item.stars_count], :class => 'star')
#    else
#      icon_tag('star_empty')
#    end
#  end

  #
  # render the cover of the page if it exists
  #
  def page_cover(page)
    thumbnail_img_tag(page.cover, :medium, :scale => '64x64') if page.cover
  end

  #
  # helper to show the information box of a page
  #
  def page_info(page, options={})
    date = friendly_date(page.updated_at)
    user = link_to_name(page.updated_by_login)
    "#{date}&nbsp;&bull;&nbsp;#{user}<br/>#{page.views_count}&nbsp;views / #{page.stars_count}&nbsp;stars / #{page.contributors_count}&nbsp;voices".html_safe

#    locals = {:page => page}

#    # status, date and username
#    field    = (page.updated_at > page.created_at + 1.hour) ? 'updated_at' : 'created_at'
#    is_new = field == 'updated_at'
#    status    = is_new ? I18n.t(:page_list_heading_updated) : I18n.t(:page_list_heading_new)
#    username = link_to_user(page.updated_by_login)
#    date     = friendly_date(page.send(field))
#    locals.merge!(:status => status, :username => username, :date => date)

#    if options.has_key?(:columns)
#      locals.merge!(:views_count => page.views_count) if options[:columns].include?(:views)
#      if options[:columns].include?(:stars)
#        star_icon = page.stars_count > 0 ? icon_tag('star') : icon_tag('star_empty')
#        locals.merge!(:stars_count => content_tag(:span, "%s %s" % [star_icon, page.stars_count]))
#      end
#      locals.merge!(:contributors =>  content_tag(:span, "%s %s" % [image_tag('ui/person-dark.png'), page.stars_count])) if options[:columns].include?(:contributors)
#    end

#    render :partial => 'pages/information_box', :locals => locals

#%ul.pages-status
#  %li= username
#  %li= status + " &bull; " + date
#  %li= "Views: #{views_count}" if local_assigns[:views_count]
#  %li= contributors if local_assigns[:contributors]
#  %li= stars_count if local_assigns[:stars_count]
  end


  def page_summary(page)
    text_with_more(page.summary, :length => 300)
  end

  #def owner_image(page, options={})
  #  return unless page.owner
  #  display_name = page.owner.respond_to?(:display_name) ? page.owner.display_name : ""
  #  url = url_for_entity(page.owner)
  #  img_tag = avatar_for page.owner, 'small'
  #  if options[:with_tooltip]
  #    owner_entity = I18n.t((page.owner.is_a?(Group) ? 'group' : 'user').to_sym).downcase
  #    details = I18n.t(:page_owned_by, :title => page.title, :entity => owner_entity, :name => display_name)
  #    render :partial => 'pages/page_details', :locals => {:url => url, :img_tag => img_tag, :details => details}
  #  else
  #    link_to(img_tag, url, :class => 'imglink tooltip', :title => display_name)
  #  end
  #end


end

