module MePermission

  protected

  # always have access to self
  def may_access_me?
    logged_in?
  end

  ##
  ## POSTS
  ##

  def may_create_post?
    current_user.may?(:pester, @recipient)
  end

  def may_edit_post?(post=@post)
    logged_in? and
    post and
    post.user_id == current_user.id
  end

  alias_method :may_update_post?, :may_edit_post?

  def may_index_post?
    true
  end

end
