#
# See for other ways of doing ajax pagination:
#  http://weblog.redlinesoftware.com/2008/1/30/willpaginate-and-remote-links
#
#
class LinkRenderer::Ajax < LinkRenderer::Dispatch
  def page_link(page, text, attributes = {})
    # ajax pagination will always use :get as the method
    # because the action should be index (or possibly show)
    options = {:url => url_for(page), :method => :get, :loading => @template.show_spinner(spinner_id)}

    # set up arrows
    # if attributes[:class] =~ /prev_page/
    #   attributes[:icon] = 'left'
    #   attributes[:style] = 'padding-left: 20px'
    # elsif attributes[:class] =~ /next_page/
    #   attributes[:icon] = 'right'
    #   attributes[:class] += ' right'
    #   attributes[:style] = 'padding-right: 20px'
    # else
    #  attributes[:icon] = 'none'
    # end

    @template.link_to_remote(text, options, attributes)
  end

  def page_span(page, text, attributes = {})
    # if attributes[:class] =~ /prev_page/
    #  attributes[:class] += " small_icon left_16"
    #  attributes[:style] = 'padding-left: 20px'
    # elsif attributes[:class] =~ /next_page/
    #  attributes[:class] += " small_icon right_16 right"
    #  attributes[:style] = 'padding-right: 20px'
    # end
    @template.content_tag :span, text, attributes
  end

  def to_html
    # we want the spinner inside the pagination container div, so we override the
    # default container and define one here:
    @template.content_tag :div, :class => 'pagination' do
      super + ' ' + @template.spinner(spinner_id)
    end
  end

  def spinner_id
    # eg, if we are paginating user_participations, results in spinners with
    # id => 'pagination_user_participation_spinner'
    'pagination_' + @collection.first.class.name.underscore
  end

end

