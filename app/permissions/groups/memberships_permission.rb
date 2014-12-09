module Groups::MembershipsPermission

  protected

  ##
  ## CREATION
  ##

  #
  # may current_user join the group immediately?
  #
  # for requests, see may_create_join_request?
  #
  def may_join_group?(group=@group)
    logged_in? and
    group and
    (current_user.may?(:admin, group) or current_user.may?(:join, group)) and
    !current_user.direct_member_of?(group)
  end

  #
  # may the current user add someone directly to a group without sending them an invite first?
  #
  # currently, this is possible only if the group is a committee and the user is in the parent group.
  #
  def may_create_membership?(group=@group, user=@user)
    logged_in? and
    group and
    group.parent and
    current_user.may?(:admin, group) and
    ((user && user.member_of?(group.parent)) || user.nil?)
  end

  ##
  ## DESTRUCTION
  ##

  #
  # may the current_user leave the group?
  #
  # you can leave a group if it has more than one member
  # or it is a network or committee.
  #
  def may_leave_group?(group = @group)
    logged_in? and
    current_user.direct_member_of?(group) and
    (group.network? or group.committee? or group.users.uniq.size > 1)
  end

  #
  # permission for immediately removing someone from a group.
  # this is possible if one of two conditions is true:
  #
  # (1) there is a council, the current_user is in the council, but the other user is not.
  # (2) the group in question is a committee, and current_user may admin parent group
  #
  # for most other cases, use may_create_expell_request?
  #
  def may_destroy_membership?(membership = @membership)
    group = membership.group
    user = membership.user
    (
      current_user.council_member_of?(group) &&
      !user.council_member_of?(group) &&
      user != current_user
    ) || (
      group.committee? &&
      current_user.may?(:admin, group.parent)
    )
  end

  ##
  ## INDEX, SHOW
  ##

  def may_list_memberships?
    current_user.may? :see_members, @group
  end

  ##
  ## MEMBERSHIP REQUESTS
  ##

  #
  # may request to join the group?
  #
  def may_create_join_request?(group=@group)
    logged_in? and
    group and
    current_user.may?(:request_membership, group) and
    !current_user.member_of?(group)
  end

  #
  # may request to kick someone out of the group?
  #
  # currently, this ability is limited to 'longterm' members.
  # see RequestToRemoveUser.may_create?
  #
  def may_create_expell_request?(membership=@membership)
    group = membership.group
    user = membership.user
    current_user.may?(:admin, group) && (
      group.committee? || (
        !RequestToRemoveUser.existing(user: user, group: group) &&
        RequestToRemoveUser.may_create?(current_user: current_user, user: user, group: group)
      )
    )
  end

end
