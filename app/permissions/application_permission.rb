module ApplicationPermission

  protected

  def may_admin_site?
    # make sure we actually have a site
    logged_in? and
    !current_site.new_record? and
    current_user.may?(:admin, current_site)
  end
  def may_create_pages?
    logged_in?
  end
  alias_method :may_create_wiki_pages?, :may_create_pages?

  def may_signup?
    if current_site.signup_mode == Conf::SIGNUP_MODE[:invite_only]
      session[:user_has_accepted_invite] == true
    elsif current_site.signup_mode == Conf::SIGNUP_MODE[:closed]
      false
    else
      true
    end
  end

end
