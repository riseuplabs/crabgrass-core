#
# Responsible for modifying the session (login, logout, and language setting)
#

class SessionController < ApplicationController

  layout 'notice'
  skip_before_filter :redirect_unverified_user

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      rebuild_session # prevent session fixation attacks!
    else
      error [I18n.t(:login_failed), I18n.t(:login_failure_reason)], :later
    end
    redirect_to referrer
  end

  def logout
    if logged_in?
      # i think the remember me stuff is a security flaw, so it is commented out for now:
      #self.current_user.forget_me if logged_in?
      #cookies.delete :auth_token
      logout!
      success [:logout_success.t, :logout_success_message.t]
    end
    redirect_to '/'
  end

  # set the language of the current session
  def language
    session[:language_code] = params[:id]
    redirect_to referrer
  end

  # returns login form without layout.
  # used for ajax login form.
  def login_form
    render partial: 'session/login_form', layout: false, content_type: "text/html"
  end

  protected

  def rebuild_session
    previous_language = session[:language_code]
    reset_session
    self.current_user = User.authenticate(params[:login], params[:password])

    if current_user.language.present?
      session[:language_code] = self.current_user.language.to_sym
    else
      session[:language_code] = previous_language
    end
  end
end
