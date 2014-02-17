module PostsPermission

  def may_create_post?
    return false unless logged_in?
    if @recipient
      may_message? and current_user.may?(:pester, @recipient)
    elsif @page
      current_user.may?(:edit, @page) or
      ( current_user.may?(:view, @page) and @page.public_comments? )
    end
  end

  def may_edit_post?(post=@post)
    logged_in? and
    (@page || may_message?) and
    post and
    post.user_id == current_user.id
  end

  alias_method :may_update_post?, :may_edit_post?

  def may_index_post?
    may_message?
  end

  def may_twinkle_posts?(post=@post)
    logged_in? and
    post.discussion.page and
    current_user.may?(:view, post.discussion.page) and
    current_user.id != post.user_id
  end
end
