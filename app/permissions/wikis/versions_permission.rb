module Wikis::VersionsPermission

  include WikiPermission
  protected

  def may_revert_wiki_version?(version = @version)
    version.next && may_edit_wiki?(version.wiki)
  end

  alias_method :may_list_wiki_versions?,   :may_edit_wiki?
  alias_method :may_destroy_wiki_version?, :may_admin_wiki?

end
