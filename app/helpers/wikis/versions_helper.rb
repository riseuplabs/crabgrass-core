module Wikis::VersionsHelper

  def classes_for_versions_list(version)
    version == @version ?
      cycle('odd', 'even') + ' active' :
      cycle('odd', 'even')
  end

  def previous_version_link
    link_to_version LARROW + :pagination_previous.t, @version.previous
  end

  def next_version_link
    link_to_version :pagination_next.t + RARROW, @version.next
  end

  def version_number_link(version)
    link_to_version version.version, version
  end

  def version_time_link(version)
    link_to_version friendly_date(version.updated_at), version
  end

  def link_to_version(content, version)
    return unless version
    link_to_remote content, :url => wiki_version_path(@wiki, version),
      :method => :get
  end

  def version_user_link(version)
    link_to_user(version.user, :avatar => :xsmall) if version.user
  end

 def version_user_link_small(version)
   link_to avatar_for(version.user, :xsmall, {:title => version.user.name}), entity_path(version.user) if version.user
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
