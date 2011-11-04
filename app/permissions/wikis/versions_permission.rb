module Wikis::VersionsPermission

  protected

  def may_revert_wiki_version?(wiki = @wiki)
    may_admin_wiki?(wiki)
  end

  def may_destroy_wiki_version?(wiki = @wiki)
    may_admin_wiki?(wiki)
  end
end
