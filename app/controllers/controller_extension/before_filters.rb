
module ControllerExtension::BeforeFilters

  def self.included(base)
    base.class_eval do
      # the order of these filters matters. change with caution.
      before_filter :essential_initialization
      before_filter :set_language
      before_filter :set_timezone
      before_filter :header_hack_for_ie6
      before_filter :redirect_unverified_user
      before_render :context_if_appropriate
      before_filter :enforce_ssl_if_needed
    end
  end

  protected

  # ensure that essential_initialization ALWAYS comes first
  def self.prepend_before_filter(*filters, &block)
    filter_chain.skip_filter_in_chain(:essential_initialization, &:before?)
    filter_chain.prepend_filter_to_chain(filters, :before, &block)
    filter_chain.prepend_filter_to_chain([:essential_initialization], :before, &block)
  end

  private

  def enforce_ssl_if_needed
    request.session_options[:secure] = current_site.enforce_ssl
  end

  def essential_initialization
    # current_site
  end

  def header_hack_for_ie6
    #
    # the default http header cache-control in rails is:
    #    Cache-Control: "private, max-age=0, must-revalidate"
    # on some versions of ie6, this break the back button.
    # so, for ie6, we set it to:
    #    Cache-Control: "max-age=Sun Aug 10 15:18:40 -0700 2008, private"
    # (where the date specified is right now)
    #
    expires_in Time.now if request.user_agent =~ /MSIE 6\.0/
  end

  def redirect_unverified_user
    if logged_in? and current_user.unverified?
      redirect_to account_url(:action => 'unverified')
    end
  end

  # an around filter responsible for setting the current language.
  # order of precedence in choosing a language:
  # (1) the current session
  # (2) the current_user's settings
  # (3) the request's Accept-Language header
  # (4) the site default
  # (5) english
  def set_language
    session[:language_code] ||= begin
      if I18n.available_locales.empty?
        'en'
      elsif !logged_in? || current_user.language.empty?
        code = request.compatible_language_from(I18n.available_locales)
        code ||= current_site.default_language
        code ||= 'en'
        code.to_s.sub('-', '_').sub(/_\w\w/, '')
      else
        current_user.language
      end
    end

    I18n.locale = session[:language_code].to_sym
  end

  # if we have login_required this will be called and check the
  # permissions accordingly
  def authorized?
    check_permissions!
  end

  # set the current timezone, if the user has it configured.
  def set_timezone
    Time.zone = current_user.time_zone if logged_in?
  end


  ##
  ## CONTEXT
  ## 

  private

  #
  # A special 'before_render' filter that calls 'context()' if this is a normal
  # request for html and there has not been a redirection. This allows
  # subclasses to put their navigation setup calls in context() because
  # it will only get called when appropriate.
  #
  def context_if_appropriate
    if !@skip_context and normal_request?
      @skip_context = true
      context()
      navigation()
    end
    true
  end

  # Returns true if the current request is of type html and we have not
  # redirected. However, IE 6 totally sucks, and sends the wrong request
  # which sometimes appears as :gif.
  def normal_request?
    format = request.format.to_sym
    response.redirected_to.nil? and
    (format == :html or format == :all or format == :gif)
  end

  protected

  #
  # a "before_render" filter that may be overridden by controllers.
  #
  # context() is called right before rendering starts (by the filter method
  # context_if_appropriate). in this method, the controller should set the
  # @context variable
  #
  def context
    @context = nil
  end

  #
  # sets up the navigation variables from the current theme.
  # The 'active' blocks of the navigation definition are evaluated in this
  # method, so any variables needed by those blocks must be set up before this
  # is called.
  #
  # I don't see any reason why a controller would want to override this, but they
  # could if they really wanted to.
  #
  def navigation
    current_theme.controller = self
    @global_navigation  = current_theme.navigation.root
    @context_navigation = @global_navigation.currently_active_item  if @global_navigation
    @local_navigation   = @context_navigation.currently_active_item if @context_navigation
  end

end

