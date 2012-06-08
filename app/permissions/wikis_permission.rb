module WikisPermission

  protected

  def may_show_wiki?(wiki = @wiki)
    if wiki.profile && wiki.profile.private?
      may_edit_wiki? wiki
    else
      current_user.may?(:view, (wiki.page || wiki.group))
    end
  end

  def may_edit_wiki?(wiki = @wiki)
    current_user.may?(:edit, (wiki.page || wiki.group))
  end

  def may_admin_wiki?(wiki = @wiki)
    current_user.may?(:admin, (wiki.page || wiki.group))
  end

  def may_revert_wiki_version?(version = @version)
    version.next && may_edit_wiki?(version.wiki)
  end

  def may_show_wiki_diff?(version = @version)
    version.previous and may_edit_wiki?(version.wiki)
  end

end

