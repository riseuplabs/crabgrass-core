module Groups::DirectoryHelper

  #
  # entry for group directory
  #
  def group_entry(group)
    place = h(group.profiles.public.place)
    count = :group_membership_count.t(count: group.users.count)
    summary = group.profiles.public.summary_html
    if may_list_group_committees?(group)
      committees = group.real_committees
    else
      committees = nil
    end

    haml do
      haml '.name', link_to_group(group)
      haml '.display-name', group.display_name if group.display_name != group.name
      haml '.info', comma_join(place, count)
      if summary && summary.chars.any?
        haml '.summary.plain', strip_tags(summary)
      end
      if committees.present?
        haml '.committees' do
          for cmtee in committees
            haml avatar_link(cmtee, 'xsmall')
          end
        end
      end
    end
  end

end

