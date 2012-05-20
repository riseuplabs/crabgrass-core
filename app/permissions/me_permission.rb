module MePermission

  protected

  # always have access to self
  def may_access_me?
    logged_in?
  end

end
