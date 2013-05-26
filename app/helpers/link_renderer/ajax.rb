#
# See for other ways of doing ajax pagination:
#  http://weblog.redlinesoftware.com/2008/1/30/willpaginate-and-remote-links
#
#
class LinkRenderer::Ajax < LinkRenderer::CrabgrassBase

  def page_link_to(page, text, attributes = {})
    @template.link_to_remote(text, link_options(page), attributes)
  end

  #def html_after
  #  @template.spinner(spinner_id)
  #end

  def spinner_id
    # eg, if we are paginating user_participations, results in spinners with
    # id => 'pagination_user_participation_spinner'
    "pagination_#{@collection.first.class.name}".gsub('/', '_').underscore
  end

  protected

  # overwritten by LinkRenderer::ModalAjax
  def link_options(page)
    # ajax pagination will always use :get as the method
    # because the action should be index (or possibly show)
    options = {
      :url => url_for(page),
      :method => :get,
      :loading => @template.show_spinner(spinner_id)
    }
  end

end

