module Wikis::VersionsPermission

  include WikiPermission
  protected

  def may_revert_wiki_version?(version = @version)
    version.next && may_edit_wiki?(version.wiki)
  end

  def may_show_wiki_diff?(version = @new)
    version.previous && may_show_wiki_versions?
  end

  alias_method :may_show_wiki_versions?,   :may_edit_wiki?
  alias_method :may_list_wiki_versions?,   :may_edit_wiki?
  alias_method :may_destroy_wiki_version?, :may_admin_wiki?

end
