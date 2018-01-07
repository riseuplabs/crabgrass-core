class User::ParticipationPolicy < ApplicationPolicy
  # this tests page permissions and it also lets us know if something
  # horrible would happen if we removed this participation.
  # may_admin_page_without is an expensive call, so this should be used
  # sparingly. this method helps prevent removing yourself from page access,
  # although it is clumsy.
  def destroy?
    return false unless page_policy.admin?
    if record.user_id != user.id
      true
    elsif record.user_id == page.owner_id and page.owner_type == 'User'
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
