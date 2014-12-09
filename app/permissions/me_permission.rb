module MePermission

  protected

  # always have access to self
  def may_access_me?
    logged_in?
  end

  # disabled in some sites to remove
  def may_message?
    may_access_me?
  end

end
