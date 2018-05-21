module PostsPermission
  protected

  def may_create_post?
    if @recipient
      current_user.may?(:pester, @recipient)
    elsif @page
      current_user.may?(:view, @page) or
        (@page.public? && logged_in?)
    end
  end

  def may_edit_post?(post = @post)
    post and
      post.user_id == current_user.id
  end

  alias may_destroy_post? may_edit_post?

end
