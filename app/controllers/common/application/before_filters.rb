module Common::Application::RenderWithViewSetup

  def render(*args)
    setup_theme
    super(*args)
  end


end

module Common::Application::BeforeFilters
  extend ActiveSupport::Concern

  included do
    # the order of these filters matters. change with caution.
    before_action :set_session_locale
    before_action :set_session_timezone
    before_action :header_hack_for_ie6
    before_action :redirect_unverified_user
  end

  private

  prepend Common::Application::RenderWithViewSetup

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
      redirect_to account_url(action: 'unverified')
    end
  end

  # Filter method to enforce a login requirement.
  #
  # By default we require login for all actions.
  #
  # To not require logins for specific actions, use this in your controllers:
  #
  #   skip_before_action :login_required, :only => [ :view, :index ]
  #
  # To not require them for any action:
  #
  #   skip_before_action :login_required
  #
  def login_required
    process_login
    raise AuthenticationRequired unless logged_in?
  end

  #
  # sets the current locale
  #
  def set_session_locale
    session[:language_code] = nil unless language_allowed?(session[:language_code])
    session[:language_code] ||= discover_language_code
    I18n.locale = session[:language_code].to_sym
  end

  #
  # set the current timezone, if the user has it configured.
  #
  def set_session_timezone
    Time.zone = current_user.time_zone
  rescue ArgumentError # invalid string
    Rails.logger.warn "Invalid time zone #{current_user.time_zone} for user #{current_user.login}"
    Time.zone = Time.zone_default
  end

  #
  # the theme needs a pointer to the controller for this request.
  # I am not sure if this will cause problems with multi-threaded servers.
  #
  def setup_theme
    current_theme.controller = self
  end

  #
  # @context needs to be set in the current controller.
  # This can be done by overwriting setup_context.
  # Calling super in the end will make sure @group and @user get set.
  #
  def setup_context
    # Typically, the correct @user or @group should be loaded in
    # by the dispatcher. However, there might arise cases where the
    # url does not actually contain the correct entity for the
    # current context. In these cases, we ensure @group or @user is
    # set, as appropriate.

    if @context
      if @user.nil? and @context.is_a?(Context::User)
        @user = @context.entity
      elsif @group.nil? and @context.is_a?(Context::Group)
        @group = @context.entity
      end
    end
  end

  private

  #
  # we only allow the session to set a language that has been
  # enabled in the crabgrass configuration.
  #
  def language_allowed?(lang_code)
    Conf.enabled_languages_hash[lang_code]
  end

  #
  # order of precedence in choosing a language:
  # (1) the current session
  # (2) the current_user's settings
  # (3) the request's Accept-Language header
  # (4) the site default
  # (5) english
  #
  def discover_language_code
    if I18n.available_locales.empty?
      'en'
    elsif !logged_in? || current_user.language.empty?
      if Conf.enabled_languages.any?
        code = http_accept_language.compatible_language_from(Conf.enabled_languages)
      else
        code = http_accept_language.user_preferred_languages.first
      end
      code ||= current_site.default_language
      code ||= 'en'
      code.to_s.sub('-', '_').sub(/_\w\w/, '')
    elsif language_allowed?(current_user.language)
      current_user.language
    else
      'en'
    end
  end
end
