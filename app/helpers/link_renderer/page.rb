#
# This is a link renderer that makes nice URLs for the pagination links on 
# a Page, regardless of what kind of funky action in the current params.
#
# for example, suppose the request was for /pages/25/posts/create, we still
# create links that look like /:context/:page_name?posts=2
#

class LinkRenderer::Page < WillPaginate::LinkRenderer
  # page        --> the pagination page (integer)
  # page_object --> the object of class Page
  def url_for(page)
    page_object = @template.instance_variable_get('@page')
    if page_object
      return @template.page_path(page_object, param_name => page)
    else
      super(page)
    end
  end
end

