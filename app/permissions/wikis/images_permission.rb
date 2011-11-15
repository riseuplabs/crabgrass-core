module Wikis::ImagesPermission

  include WikiPermission
  protected

  alias_method :may_create_wiki_image?, :may_edit_wiki?

end
