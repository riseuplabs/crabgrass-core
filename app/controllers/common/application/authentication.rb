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
      user ||= User::Unknown.new
      user
    end
  end

  #
  # Store the given user in the session.
  #
  def current_user=(new_user)
    new_user = nil unless new_user.respond_to? :id
    session[:user] = new_user.nil? ? nil : new_user.id
    @current_user = new_user
  end

  #
  # Returns true if the user is logged in.
  #
  def logged_in?
    current_user.is_a?(User::Authenticated)
  end

  #
  # destroys the current session, keeping the current language
  #
  def logout!
    language = session[:language_code]
    reset_session
    session[:language_code] = language
  end

  private

  def load_user(id)
    user = User.find_by_id(id)
    user.seen! if user
    user
  end
end
