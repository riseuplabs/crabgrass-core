#
# Responsible for modifying the session (login, logout, and language setting)
#

class SessionController < ApplicationController

  layout 'notice'
  skip_before_filter :redirect_unverified_user

  def login
    return unless request.post?
    previous_language = session[:language_code]
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      reset_session # important!!
                    # always force a new session on every login success
                    # in order to prevent session fixation attacks.
      # have to reauth, since we just cleared the session
      self.current_user = User.authenticate(params[:login], params[:password])

      # i feel like this is a security flaw, and i don't like it....
      #if params[:remember_me] == "1"
      #  self.current_user.remember_me
      #  cookies[:auth_token] = {
      #    :value => self.current_user.remember_token,
      #    :expires => self.current_user.remember_token_expires_at
      #  }
      #end

      if self.current_user.language.present?
        session[:language_code] = self.current_user.language.to_sym
      else
        session[:language_code] = previous_language
      end

      # replace this:
      #current_site.add_user!(current_user)
      #Activity::Unread.create(:user => current_user)
      # with
      # hook(:successful_login)

      redirect_successful_login
    else
      error [I18n.t(:login_failed), I18n.t(:login_failure_reason)], :now
    end

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

  # where to go when the user logs in?
  def redirect_successful_login
    if params[:redirect].is_a?(String) && !params[:redirect].index(':')
      redirect_to params[:redirect], only_path: true
    else
      redirect_to current_site.login_redirect(current_user)
    end
  end

end
