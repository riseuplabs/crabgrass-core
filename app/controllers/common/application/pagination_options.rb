# handles pagination options for all controllers
# they should override these methods for special behavior

module Common::Application::PaginationOptions

  def self.included(base)
    base.class_eval do
      helper_method :pagination_params
      helper_method :pagination_link_renderer
    end
  end

  protected

  def pagination_default_page
    # nil is fine here, it leaves up to will_paginate to decide what it wants to do
    nil
  end

  # if +:page+ is not set, it will try params[:page] and then default page (usually nil)
  # if +:per_page+ is not set, it will leave it to will_paginate.
  # will_paginate uses the models per_page setting or the default from Conf
  def pagination_params(opts = {})
    page = opts[:page] || params[:page] || pagination_default_page
    per_page = opts[:per_page]

    {:page => page, :per_page => per_page }
  end

  #
  # This is a rough guess for which renderer to use.
  # Please overwrite it in the controller or set a different
  # renderer in the options of pagination_links
  #
  def pagination_link_renderer
    if defined? page_search_path
      if xhr_page_search?
        LinkRenderer::AjaxPages
      else
        LinkRenderer::Pages
      end
    elsif request.xhr?
      (request.format == :html) ?
        LinkRenderer::ModalAjax :
        LinkRenderer::Ajax
    else
      LinkRenderer::Dispatch
    end
  end

end
