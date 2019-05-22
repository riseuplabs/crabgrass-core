module Wikis::VersionsHelper
  #
  # NAVIGATION LINKS
  #
  def next_version_link
    version = @version.version + 1
    if version <= @wiki.versions.count
      link_to :next.t, wiki_version_path(@wiki, version),
        remote: true,
        method: :get,
        class: 'btn btn-default',
        icon: 'left'
    else
      "<span class='btn btn-default disabled icon left_16'>#{:next.t}</span>".html_safe
    end
  end

  def previous_version_link
    version = @version.version - 1
    if version >= 1
      link_to :previous.t, wiki_version_path(@wiki, version),
        remote: true,
        method: :get,
        class: 'btn btn-default right',
        icon: 'right'
    else
      "<span class='btn btn-default disabled icon right_16 right'>#{:previous.t}</span>".html_safe
    end
  end
end
