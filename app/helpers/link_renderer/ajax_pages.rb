#
# This is a link renderer for page lists that are ajax based.
#
# For example:
#   with url: me/pages#/public/page/3
#   then: the link to 'next' will submit an ajax request with {:add => '/page/4'}
#
class LinkRenderer::AjaxPages < LinkRenderer::Ajax
  def page_link_to(page, text, attributes = {})
    options = {
      url: @template.page_search_path(add: "/page/#{page}"),
      with: 'FilterPath.encode()',
      method: :get,
      loading: @template.show_spinner(spinner_id)
    } # FIXME: some JS needed here for with and loading
    @template.link_to(text, options.merge(remote: true), attributes)
  end
end
