#
# This is a link renderer that makes nice URLs for the pagination links when
# we happen to be on a page with a funky dispatch based route.
# eg: /:context/:page
#

class LinkRenderer::Dispatch < LinkRenderer::CrabgrassBase
  def url_for(page)
    if @template.params[:_context] or @template.params[:_page]
      url = ""
      url += "/#{@template.params[:_context]}" if @template.params[:_context]
      url += "/#{@template.params[:_page]}" if @template.params[:_page]
      url += "/#{@options[:params][:action]}" if @options[:params] and @options[:params][:action]
      url += "?#{param_name}=#{page}"
      # TODO: handle other params in addition to :action.
      return url
    else
      super(page)
    end
  end
end

