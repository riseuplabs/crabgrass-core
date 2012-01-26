# handles pagination options for all controllers
# they should override these methods for special behavior

module Common::Application::PaginationOptions

  def self.included(base)
    base.class_eval do
      helper_method :pagination_params
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
end
