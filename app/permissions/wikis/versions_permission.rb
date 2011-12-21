module Wikis::VersionsPermission

  include WikisPermission
  protected

  def may_revert_wiki_version?(version = @version)
    version.next && may_edit_wiki?(version.wiki)
  end

  def may_show_wiki_diff?(version = @version)
    version.previous and may_show_wiki_version?(version)
  end

  def may_show_wiki_version?(version = @version)
    may_edit_wiki?
  end

  alias_method :may_list_wiki_versions?,   :may_edit_wiki?
  alias_method :may_destroy_wiki_version?, :may_admin_wiki?

end
