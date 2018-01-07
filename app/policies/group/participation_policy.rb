class Group::ParticipationPolicy < ApplicationPolicy
  # this tests page permissions and it also lets us know if something
  # horrible would happen if we removed this participation.
  # may_admin_page_without is an expensive call, so this should be used
  # sparingly. this method helps prevent removing yourself from page access,
  # although it is clumsy.
  def destroy?
    return false unless page_policy.admin?
    return true unless user.member_of?(record.group)
    if record.group_id == page.owner_id and @page.owner_type == 'Group'
        false
    else
      user.may_admin_page_without?(page, record)
    end
  end

  protected

  def page_policy
    Pundit.policy!(user, page)
  end

  def page
    record.page
  end
end
