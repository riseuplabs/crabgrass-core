module MePermission

  protected

  # always have access to self
  def may_access_me?
    logged_in?
  end

  # Messages
  alias_method :may_create_posts?, :may_access_me?

end
