module Wikis::VersionsHelper

  def previous_version_link
    return unless target = @version.previous
    link_to_remote LARROW + :pagination_previous.t,
      :url => wiki_version_path(@wiki, target),
      :update => 'wiki-area',
      :method => :get
  end

  def next_version_link
    return unless target = @version.next
    link_to_remote :pagination_next.t + RARROW,
      :url => wiki_version_path(@wiki, target),
      :update => 'wiki-area',
      :method => :get
  end

  def version_number_link(version)
    label = I18n.t :version_number, :version => version.version
    link_to_remote label, :url => wiki_version_path(@wiki, version),
      :update => 'wiki-area',
      :method => :get
  end

  def version_time_link(version)
    link_to_remote full_time(version.updated_at),
      :url => wiki_version_path(@wiki, version),
      :update => 'wiki-area',
      :method => :get
  end

  def version_user_link(version)
    link_to_user(version.user, :avatar => :xsmall) if version.user
  end
end
