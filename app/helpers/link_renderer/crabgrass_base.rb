#
# This is a link renderer that all our other custom link renderers inherit from.
#
class LinkRenderer::CrabgrassBase < WillPaginate::LinkRenderer

  def page_link(page, text, attributes = {})
    @template.content_tag(:li, page_link_to(page, text, attributes))
  end

  def page_span(page, text, attributes = {})
    if attributes[:class] =~ /disabled/
      li_class = 'disabled'
    elsif attributes[:class] =~ /current/
      li_class = 'active'
    end
    attributes[:class] = nil
    @template.content_tag(:li, :class => li_class) do
      @template.link_to(text, '#', attributes)
    end
  end

  def gap_marker
    '<li class="disabled"><a href="#">&hellip;</a></li>'
  end

  #
  # subclasses should override
  #
  def page_link_to(page, text, attributes)
    @template.link_to(text, url_for(page), attributes)
  end

  #
  # override the default to_html
  #
  def to_html
    links = @options[:page_links] ? windowed_links : []
    # previous/next buttons
    links.unshift page_link_or_span(@collection.previous_page, 'disabled prev_page', @options[:previous_label])
    links.push    page_link_or_span(@collection.next_page,     'disabled next_page', @options[:next_label])
    # links
    links_html = links.join(@options[:separator])
    links_html = links_html.html_safe if links_html.respond_to? :html_safe
    @template.content_tag(:div, :class => @options[:class]) do
      html_before + @template.content_tag(:ul) do
        links_html
      end + html_after
    end
  end

  # may be overridden by subclasses
  def html_before
    ""
  end
  def html_after
    ""
  end

end
