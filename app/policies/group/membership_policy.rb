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
    if record.is_a?(Group::Membership)
      group =record.group
      record_user = record.user
      (
        user.council_member_of?(group) &&
        !record_user.council_member_of?(group) &&
        record_user != user
      ) || (
        group.committee? &&
        user.may?(:admin, group.parent)
      )
    end
  end

  #
  # may request to kick someone out of the group?
  #
  # currently, this ability is limited to 'longterm' members.
  # see RequestToRemoveUser.may_create?
  #
  def may_create_expell_request?
    if record.is_a?(Group::Federating)
      group = record.group
      network = record.network
      user.may?(:admin, network) && (
        (
          !RequestToRemoveGroup.existing(group: group, network: network) &&
          RequestToRemoveGroup.may_create?(current_user: user, group: group, network: network)
        )
      )
    else
      group = record.group
      record_user = record.user
      user.may?(:admin, group) && (
        group.committee? || (
          !RequestToRemoveUser.existing(user: record_user, group: group) &&
          RequestToRemoveUser.may_create?(current_user: user, user: record_user, group: group)
        )
      )
    end
  end
end
