module Wikis::VersionsHelper

  def previous_version_link
    return unless target = @version.previous
    link_to LARROW + :pagination_previous.t, wiki_version_path(@wiki, target)
  end

  def next_version_link
    return unless target = @version.next
    link_to :pagination_next.t + RARROW, wiki_version_path(@wiki, target)
  end
end
