module Wikis::VersionsHelper

  def short_description(version)
    "Version " + version.version.to_s +
      " created by " +
      version_user_link(version)
  end

  def version_user_link(version)
    if version.user
      link_to_user(version.user)
    else
      ''
    end
  end

  def version_action_links(version)
    link_line version_diff_link(version),
      version_revert_link(version),
      version_delete_link(version)
  end

  def version_diff_link(version)
    return unless version.previous
    link_to_remote :diff_link.t,
      :url => wiki_diff_path(@wiki, version.diff_id),
      :method => :get
  end

  def version_revert_link(version)
    return unless may_revert_wiki_version?(version)
    link_to :wiki_version_revert_link.t,
      revert_wiki_version_path(@wiki, version)
  end

  def version_delete_link(version)
    return unless may_destroy_wiki_version?
    link_to :wiki_version_destroy_link.t,
      wiki_version_path(@wiki, version), :method => :delete
  end
end
