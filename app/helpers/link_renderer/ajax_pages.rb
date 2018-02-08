#
# This is a link renderer for page lists that are ajax based.
#
# For example:
#   with url: me/pages#/public/page/3
#   then: the link to 'next' will submit an ajax request with {:add => '/page/4'}
#
class LinkRenderer::AjaxPages < LinkRenderer::Ajax
  def page_link_to(page, text, attributes = {})
    url = @template.page_search_path(add: "/page/#{page}")
    options = {
      remote: true,
      method: :get,
      data: { with: 'FilterPath.encode()', loading: @template.show_spinner(spinner_id) }
    }
    @template.link_to(text, url, options.merge(attributes))
  end
end
