#
# See for other ways of doing ajax pagination:
#  http://weblog.redlinesoftware.com/2008/1/30/willpaginate-and-remote-links
#
#
class LinkRenderer::Ajax < LinkRenderer::CrabgrassBase
  def page_link_to(page, text, attributes = {})
    @template.link_to text, url_for(page),
      link_options.merge(attributes)
  end

  def html_after
    @template.spinner(spinner_id)
  end

  def spinner_id
    # eg, if we are paginating user_participations, results in spinners with
    # id => 'pagination_user_participation_spinner'
    "pagination_#{collection_name}"
  end

  protected

  def collection_name
    @collection.first.class.name.tr('/', '_').underscore
  end

  # overwritten by LinkRenderer::ModalAjax
  def link_options
    # ajax pagination will always use :get as the method
    # because the action should be index (or possibly show)
    options = {
      remote: :true,
      method: :get,
      data: {spin: spinner_id + '_spinner'}
    }
  end
end
