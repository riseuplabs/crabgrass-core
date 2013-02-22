module Wikis::VersionsHelper

  def short_description(version, link_to_version = false)
    version_text = "Version&nbsp;".html_safe + version.version.to_s
    if link_to_version
      version_text = link_to(version_text, wiki_version_path(@wiki, version))
    end
    version_text + " created by " + version_user_link(version)
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

  def version_show_link(version)
    return unless may_edit_wiki?(@wiki)
    link_to :version_link.t, wiki_version_path(@wiki, version)
  end

  def version_diff_link(version, remote = false)
    return unless may_show_wiki_diff?(version)
    if remote
      link_to_remote :diff_link.t,
        :url => wiki_diff_path(@wiki, version.diff_id),
        :method => :get
    else
      link_to :diff_link.t, wiki_diff_path(@wiki, version.diff_id)
    end
  end

  def version_revert_link(version)
    return unless may_revert_wiki_version?(version)
    link_to :wiki_version_revert_link.t,
      revert_wiki_version_path(@wiki, version),
      :method => :post, :remote => true
  end

  def version_delete_link(version)
    return unless may_admin_wiki?
    link_to :wiki_version_destroy_link.t,
      wiki_version_path(@wiki, version), :method => :delete, :remote => true
  end
end
