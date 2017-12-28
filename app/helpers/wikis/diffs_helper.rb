module Wikis::DiffsHelper
  # not sure this is what we want.
  # it's currently required by the Wiki::DiffsControllerTest
  # but we might have remove diffs from the UI for now.
  def back_to_wiki_link
    wiki_path(@wiki)
  end

  # some translations still have the %{user} and %{when} key.
  # TODO clean them up and remove params here.
  def comparing_changes_header
    :comparing_changes_header.t(old_version: old_version_tag,
                                new_version: new_version_tag,
                                user: content_tag(:b, link_to_user(@new.user)),
                                when: content_tag(:i, full_time(@new.updated_at))).html_safe
  end

  def old_version_tag
    content_tag :del, short_description(@old, true),
                class: 'diffmod', style: 'padding: 1px 4px;'
  end

  def new_version_tag
    content_tag :ins, short_description(@new, true),
                class: 'diffins', style: 'padding: 1px 4px;'
  end

end
