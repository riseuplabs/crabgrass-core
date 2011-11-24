module Wikis::BaseHelper

  protected

  # this will eventually go away once we move the group/wiki and page/wiki
  # controllers over

  def wiki_path(wiki = @wiki)
    url_for [wiki.context, wiki]
  end

end
