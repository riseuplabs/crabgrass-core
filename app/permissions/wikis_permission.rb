module WikisPermission

  protected

  def may_edit_wiki?(wiki = @wiki)
    logged_in? and current_user.may?(:edit, (wiki.page || wiki.group))
  end

  def may_admin_wiki?(wiki = @wiki)
    logged_in? and current_user.may?(:admin, (wiki.page || wiki.group))
  end

  def may_revert_wiki_version?(version = @version)
    version.next && may_edit_wiki?(version.wiki)
  end

  def may_show_wiki_diff?(version = @version)
    version.previous and may_edit_wiki?(version.wiki)
  end

end

