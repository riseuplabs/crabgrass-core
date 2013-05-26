#
# available to all page controllers derived from base.
#
module Pages::BaseHelper

  protected

  ##
  ## MISC HELPERS
  ##

  def page_tabs(options = {})
    options.reverse_merge! :id => 'page_tabs',
      :class => 'flat reloadable'
    formy(:cutout_tabs, options) do |f|
      yield(f)
    end
  end

  def display_page_cover(page, options={}, html_options={})
    options = {:size => :medium, :crop => "200x200"}.merge(options)
    html_options = {:class => "thumb", :alt => "thumbnail", :width => "200"}.merge(html_options)
    if page.cover.respond_to?(:thumbnail)
      link_to(thumbnail_img_tag(page.cover, options[:size], {:crop => options[:crop]}, {:class => html_options[:class]}),
        page_url(page))
    elsif page.external_cover_url
      link_to(image_tag(page.external_cover_url, :class => html_options[:class], :width => html_options[:size], :alt => html_options[:alt]), page_url(page))
    end
  end

  #def header_for_page_create(page_class)
  #  style = 'background: url(/images/pages/big/#{page_class.icon}) no-repeat 0% 50%'
  #  text = "<b>#{page_class.class_display_name}</b>: #{page_class.class_description}"
  #  content_tag(:div, content_tag(:span, text, :style => style, :class => 'page-link'), :class => 'page-class')
  #end

  def recipient_checkbox_line(recipient, options={})
    name = CGI.escape(recipient.name) # so that '+' does show up as ' '
    ret = "<label>"
    ret << check_box_tag("recipients[#{name}][send_notice]", 1, false, {:class => options[:class]})
    ret << display_entity(recipient, :avatar => :xsmall, :format => :hover)
    ret << "</label>"
  end

  def this_page_class
    @page ? @page.class_display_name.capitalize : @page_class.class_display_name.capitalize
  end

end
