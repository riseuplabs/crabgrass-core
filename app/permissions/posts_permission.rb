module PostsPermission

  protected

  def may_create_post?
    if @recipient
      current_user.may?(:pester, @recipient)
    elsif @page
      current_user.may?(:view, @page) or
      ( @page.public? && @page.public_comments? && logged_in? )
    end
  end

  def may_edit_post?(post=@post)
    post and
    post.user_id == current_user.id
  end

  alias_method :may_update_post?, :may_edit_post?

  def may_twinkle_posts?(post=@post)
    post.discussion.page and
    current_user.may?(:view, post.discussion.page) and
    current_user.id != post.user_id
  end
end
