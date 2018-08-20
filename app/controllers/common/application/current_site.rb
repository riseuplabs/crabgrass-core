module Common::Application::CurrentSite
  def self.included(base)
    base.class_eval do
      # make current_site available to the views
      helper_method :current_site
    end
  end

  protected

  # returns the (cache) of the current site.
  def current_site
    return Site.default if @current_site_disabled
    @current_site ||= begin
      host = request.host.sub(/^staging\./, '')
      Site.for_domain(host) || Site.default
    end
  end

  public

  if Rails.env.test?

    # used for testing
    def disable_current_site
      @current_site_disabled = true
    end

    # used for testing
    def enable_current_site
      @current_site = nil
      @current_site_disabled = false
    end
  end
end
