class Group::MembershipPolicy < ApplicationPolicy

  #
  # permission for immediately removing someone from a group.
  # this is possible if one of two conditions is true:
  #
  # (1) there is a council, the user is in the council, but the other user is not.
  # (2) the group in question is a committee, and user may admin parent group
  #
  # for most other cases, use may_create_expell_request?
  #
  def destroy?
    group =membership.group
    membership_user = membership.user
    (
      user.council_member_of?(group) &&
      !membership_user.council_member_of?(group) &&
      membership_user != user
    ) || (
      group.committee? &&
      user.may?(:admin, group.parent)
    )
  end

  #
  # may request to kick someone out of the group?
  #
  # currently, this ability is limited to 'longterm' members.
  # see RequestToRemoveUser.may_create?
  #
  def may_create_expell_request?
    group = membership.group
    membership_user = membership.user
    user.may?(:admin, group) && (
      group.committee? || (
        !RequestToRemoveUser.existing(user: membership_user, group: group) &&
        RequestToRemoveUser.may_create?(current_user: user, user: membership_user, group: group)
      )
    )
  end

  def membership
    record
  end

end
