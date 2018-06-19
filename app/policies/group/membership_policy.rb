class Group::MembershipPolicy < ApplicationPolicy

  def create?
    record.new_record? && user.may?(:join, group)
  end

  # Permission for immediately removing someone from a group.
  # For other cases the view helper will fall back to creating a request.
  def destroy?
    leaving? || removing_as_admin? || removing_from_committee?
  end

  protected

  # leaving the group oneself
  def leaving?
    member == user &&
    member.direct_member_of?(group) &&
      (group.network? || group.committee? || group.users.uniq.size > 1)
  end

  # there is a council, the user is in the council, but the other user is not.
  def removing_as_admin?
    user.council_member_of?(group) && !member.council_member_of?(group)
  end

  # the group in question is a committee, and user may admin parent group
  def removing_from_committee?
    (group.committee? && user.may?(:admin, group.parent))
  end

  def group
    record.group
  end

  def member
    record.user
  end
end
