module Wikis::AssetsPermission

  include WikiPermission
  protected

  alias_method :may_create_wiki_asset?, :may_edit_wiki?

end
