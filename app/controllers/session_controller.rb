#
# Responsible for modifying the session (login, logout, and language setting)
#

class SessionController < ApplicationController

  layout 'notice'
  skip_before_filter :redirect_unverified_user
  before_filter :stop_illegal_redirect, :only => [:login]
  verify :method => :post, :only => [:language, :logout]

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

      if self.current_user.language.any?
        session[:language_code] = self.current_user.language.to_sym
      else
        session[:language_code] = previous_language
      end

      # replace this:
      #current_site.add_user!(current_user)
      #UnreadActivity.create(:user => current_user)
      # with
      # hook(:successful_login)

      redirect_successful_login
    else
      error [I18n.t(:login_failed), I18n.t(:login_failure_reason)], :now
    end

  end

  def logout
    # i think the remember me stuff is a security flaw, so it is commented out for now:
    #self.current_user.forget_me if logged_in?
    #cookies.delete :auth_token
    
    language = session[:language_code]
    reset_session
    session[:language_code] = language
    success [:logout_success.t, :logout_success_message.t]
    redirect_to '/'
  end

  # set the language of the current session
  def language
    session[:language_code] = params[:id].to_sym
    redirect_to referrer
  end

  # returns login form without layout.
  # used for ajax login form.
  def login_form
    render :partial => 'session/login_form', :layout => false
  end

  protected

  # where to go when the user logs in?
  # depends on the settings (for example, unverified users should not see any pages)
  def redirect_successful_login
    params[:redirect] = nil unless params[:redirect].any?
    if current_user.unverified?
      redirect_to :controller=> 'account', :action => 'unverified'
    else
      redirect_to(params[:redirect] || current_site.login_redirect(current_user))
    end
  end

  # before filter
  def stop_illegal_redirect
    unless params[:redirect].empty? || params[:redirect] =~ /^https?:\/\/#{request.domain}/ || params[:redirect] =~ /^\//
      redirect_to params
      error [:illegal_redirect.t, :redirect_to_foreign_domain.t(:url => params.delete(:redirect))]
      false
    else
      true
    end
  end

  #
  # returns the url of the HTTP Referrer (aka Referer).
  #
  def referrer
    @referrer ||= begin
      if request.env["HTTP_REFERER"].empty?
        '/'
      else
        raw = request.env["HTTP_REFERER"]
        server = request.host_with_port
        prot = request.protocol
        if raw.starts_with?("#{prot}#{server}/")
          raw.sub(/^#{prot}#{server}/, '').sub(/\/$/,'')
        else
          '/'
        end
      end
    end
  end

end
