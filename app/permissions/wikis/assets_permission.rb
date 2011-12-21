module Wikis::AssetsPermission

  include WikisPermission
  protected

  alias_method :may_create_wiki_asset?, :may_edit_wiki?

end
