
module PublicMessagesPermission

  protected

  def may_show_public_messages?(user=@user)
    logged_in? and user and user.has_access :see
  end

  alias_method :may_index_public_messages?, :may_show_public_messages?

  # may current_user post to user's public message wall?
  def may_create_public_messages?(user=@user)
    logged_in? and
    user and
    user.has_access?(:comment)
  end

  def may_destroy_public_messages?(user=@user, post=@post)
    if !logged_in?
      false
    elsif user == current_user
      true # you can always delete the messages on your own wall
    elsif post and post.user == current_user
      true # you can delete messages you created
    else
      false
    end
  end
end

