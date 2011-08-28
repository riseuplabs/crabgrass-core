module Groups::DirectoryHelper

  #
  # entry for group directory
  #
  def group_entry(group)
    place = h(group.profiles.public.place)
    count = :group_membership_count.t(:count => group.users.count)
    summary = group.profiles.public.summary_html
    if may_list_groups_committees?(group)
      committees = group.real_committees
    else
      committees = nil
    end

    haml do
      haml '.name', link_to_group(group)
      haml '.info', comma_join(place, count)
      haml '.summary.plain', summary
      if committees.any?
        haml '.committees' do
          for cmtee in committees
            haml avatar_link(cmtee, 'xsmall')
          end
        end
      end
    end
  end

end

