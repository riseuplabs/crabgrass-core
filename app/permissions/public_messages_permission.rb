
module PublicMessagesPermission

  protected

  def may_show_public_messages?(user=@user)
    user and current_user.may?(:see, user)
  end

  # may current_user post to user's public message wall?
  def may_create_public_messages?(user=@user)
    user and current_user.may?(:comment, user)
  end

  def may_destroy_public_messages?(user=@user, post=@post)
    user == current_user or post.user == current_user
  end
end

