module Wikis::VersionsPermission

  include WikiPermission
  protected

  alias_method :may_list_wiki_versions?,   :may_edit_wiki?
  alias_method :may_show_wiki_version?,    :may_edit_wiki?
  alias_method :may_revert_wiki_version?,  :may_admin_wiki?
  alias_method :may_destroy_wiki_version?, :may_admin_wiki?

end
