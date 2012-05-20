module PostsPermission

  protected

  def may_create_page_post?
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

  def may_edit_page_post?(post=@post)
    logged_in? and
    post and
    post.user == current_user
  end

  def may_twinkle_posts?(post=@post)
    logged_in? and
    post.discussion.page and
    current_user.may?(:view, post.discussion.page) and
    current_user.id != post.user_id
  end

end
