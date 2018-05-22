module Wikis::VersionsHelper
  #
  # DISPLAY
  #

  def short_description(version, link_to_version = false)
    version_text = 'Version&nbsp;'.html_safe + version.version.to_s
    if link_to_version
      version_text = link_to(version_text, wiki_version_path(@wiki, version))
    end
    version_text + ' created by ' + version_user_link(version)
  end

  #
  # NAVIGATION LINKS
  #

  def list_versions_link
    label = :list_things.t(things: :versions.t)
    url = wiki_versions_path(@wiki)
    link_to(label, url,
      remote: true,
      method: :get,
      class: 'btn btn-default',
      icon: 'left')
  end

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

  private

  def version_user_link(version)
    if version.user
      link_to_user(version.user)
    else
      ''
    end
  end

  def version_show_link(version)
    return unless may_update?(@wiki)
    link_to :version_link.t, wiki_version_path(@wiki, version)
  end

end
