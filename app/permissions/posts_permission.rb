module PostsPermission

  protected

  def may_create_posts?
    if !logged_in?
      false
    elsif current_user.may?(:edit, @page)
      true
    elsif current_user.may?(:view, @page) and @page.public_comments?
      true
    elsif @page.public and @page.public_comments?
      false
    end
  end

  def may_edit_posts?(post=@post)
    logged_in? and
    post and
    post.editable_by?(current_user)
  end

  alias_method :may_save_posts?, :may_edit_posts?

  def may_twinkle_posts?(post=@post)
    logged_in? and
    post.discussion.page and
    current_user.may?(:view, post.discussion.page) and
    current_user.id != post.user_id
  end

  alias_method :may_untwinkle_posts?, :may_twinkle_posts?

  def may_jump_posts?
    true
  end

end
