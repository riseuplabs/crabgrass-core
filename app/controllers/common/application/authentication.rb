module Common::Application::Authentication

  def self.included(base)
    base.send :helper_method, :current_user, :logged_in?
  end

  protected

  #
  # Accesses the current user for the session.
  #
  def current_user
    @current_user ||= begin
      user = load_user(session[:user]) if session[:user]
      user ||= UnauthenticatedUser.new
      User.current = user
      user
    end
  end

  #
  # Store the given user in the session.
  #
  def current_user=(new_user)
    new_user = nil unless new_user.respond_to? :id
    session[:user] = new_user.nil? ? nil : new_user.id
    session[:logged_in_since] = Time.now
    @current_user = new_user
  end

  #
  # Returns true if the user is logged in.
  #
  def logged_in?
    current_user.is_a?(UserExtension::AuthenticatedUser)
  end

  #
  # destroys the current session, keeping the current language
  #
  def logout!
    language = session[:language_code]
    reset_session
    session[:language_code] = language
  end

  def logged_in_since
    session[:logged_in_since]
  end


  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_filter :login_required
  #
  # To require logins for specific actions, use this in your controllers:
  #
  #   before_filter :login_required, :only => [ :edit, :update ]
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_filter :login_required
  #
  def login_required
    unless current_user
      # auth using http headers
      username, passwd = get_auth_data
      if username and passwd
        self.current_user = User.authenticate(username, passwd) || UnauthenticatedUser.new
      end
    end
    User.current = current_user
    if !logged_in?
      raise_authentication_required
    else
      return authorized?
    end
  end

  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = (request.request_uri unless request.xhr?)
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end

  # When called with before_filter :login_from_cookie will check for an :auth_token
  # cookie and log the user back in if apropriate
  def login_from_cookie
    return unless cookies[:auth_token] && !logged_in?
    user = User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      user.remember_me
      self.current_user = user
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      flash[:notice] = "Logged in successfully"
    end
  end

  # note: this method is not automatically called. if you want to enable HTTP
  # authentication for some action(s), you must put a prepend_before_filter in
  # place.
  # however, a user who successfully uses HTTP auth on an action for which it
  # was enabled will stay logged in and can then go and see other things.
  # this is kind of lame. but only exploitable by people who could log in
  # anyway, so presumabbly not *too* big a security hole.
  def login_with_http_auth
    unless logged_in?
      authenticate_or_request_with_http_basic do |user, password|
        founduser = User.authenticate(user, password)
        self.current_user = founduser unless founduser.nil?
      end
    end
  end

  private

  @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
  # gets BASIC auth info
  def get_auth_data
    auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
    auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
    return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil]
  end

  def load_user(id)
    user = User.find_by_id(id)
    if user
      user.seen!
      #user.current_site = current_site
    end
    return user
  end

end
