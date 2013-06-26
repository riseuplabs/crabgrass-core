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

  ##
  ## POSTS
  ##

  def may_create_post?
    may_message? and
    current_user.may?(:pester, @recipient)
  end

  def may_edit_post?(post=@post)
    may_message? and
    post and
    post.user_id == current_user.id
  end

  alias_method :may_update_post?, :may_edit_post?

  def may_index_post?
    may_message?
  end

end
