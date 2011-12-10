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

  # THese aliases are because views (& below alias) refer to may_create_posts? and may_edit_posts?, but we should
  # fix this as we shouldn't have the separate methods for may_XX_posts? and may_XX_page_post?
  # however, i'm not sure if this even makes sense to have this as a separate permissions file, and
  # whether all this should be in pages_permission.rb anyway.
  #alias_method :may_create_posts?, :may_create_page_post?
  #alias_method :may_edit_posts?, :may_edit_page_post?


  #alias_method :may_save_posts?, :may_edit_posts?

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
