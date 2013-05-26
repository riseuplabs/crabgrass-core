#
# This is a link renderer that all our other custom link renderers inherit from.
#
class LinkRenderer::CrabgrassBase < WillPaginate::ViewHelpers::LinkRenderer

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

  def page_link_or_span(page, class_names, text)
    if page && class_names !~ /current/
      page_link page, text
    else
      page_span page, text, :class => class_names
    end
  end

  #
  # override the default to_html
  #
  def to_html
    links_html = pagination.map do |page|
      case page
      when Fixnum
        page_link_or_span(page, page == @collection.current_page ? 'current' : '', page.to_s)
      when :gap
        gap_marker
      when :previous_page, :next_page
        class_name, text = *(page == :previous_page ?
          ['prev_page', @options[:previous_label]] :
          ['next_page', @options[:next_label]])
        page_number = @collection.send(page)
        class_name += ' disabled' unless page_number
        page_link_or_span(page_number, class_name, text)
      else
        ## FIXME: are there any other cases?
        ''
      end
    end.join(@options[:separator]).html_safe
    @template.content_tag(:div, :class => @options[:class]) do
      (html_before + @template.content_tag(:ul) do
        links_html
      end + html_after).html_safe
    end
  end

  # may be overridden by subclasses
  def html_before
    ""
  end
  def html_after
    ""
  end

  def url_for(page)
    if @options[:params]
      @template.url_for(@options[:params].merge({param_name => page}))
    else
      "?#{param_name}=#{page}"
    end
  end

end
