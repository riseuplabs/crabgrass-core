module Common::Application::CurrentSite

  def self.included(base)
    base.class_eval do
      # make current_site available to the views
      helper_method :current_site
      if RAILS_ENV == 'test'
        hide_action :disable_current_site, :enable_current_site
      end
    end
  end

  protected

  # returns the (cache) of the current site.
  def current_site
    if !@current_site_disabled
      @current_site ||= begin
        host = request.host.sub(/^staging\./, '')
        site = Site.for_domain(host).find(:first)
        site ||= Site.default
        site ||= Site.new(:domain => host, :name => 'custom')
        Site.current = site
        # ^^ not so nice, but required for now. used by i18n
      end
    else
      Site.new()
    end
  end

  public

  if RAILS_ENV == 'test'

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
