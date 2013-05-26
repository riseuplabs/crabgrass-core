module Wikis::VersionsHelper

  #
  # DISPLAY
  #

  # def short_description(version, link_to_version = false)
  #   version_text = "Version&nbsp;".html_safe + version.version.to_s
  #   if link_to_version
  #     version_text = link_to(version_text, wiki_version_path(@wiki, version))
  #   end
  #   version_text + " created by " + version_user_link(version)
  # end

  #
  # NAVIGATION LINKS
  #

  def version_action_links(version)
    link_line version_diff_link(version),
      version_revert_link(version)
  end

  def show_version_remote_function(version)
    remote_function(
      :url => wiki_version_path(@wiki, version),
      :method => :get,
      :loading => 'showSpinner()',
      :loaded => 'hideSpinners()'
    )
  end

  def list_versions_link
    label = :list_things.t(:things => :versions.t)
    url = wiki_versions_path(@wiki)
    link_to_remote_with_icon(label, {:url => url, :method => :get}, {:class => 'btn', :icon => 'left'})
  end

  def next_version_link
    version = @version.version + 1
    if version <= @wiki.versions.count
      link_to_remote :next.t,
        {:url => wiki_version_path(@wiki, version), :method => :get},
        {:class => 'btn', :icon => 'left'}
    else
      "<span class='btn disabled icon left_16'>#{:next.t}</span>".html_safe
    end
  end

  def previous_version_link
    version = @version.version - 1
    if version >= 1
      link_to_remote :previous.t,
        {:url => wiki_version_path(@wiki, version), :method => :get},
        {:class => 'btn right', :icon => 'right'}
    else
      "<span class='btn disabled icon right_16 right'>#{:previous.t}</span>".html_safe
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
end
