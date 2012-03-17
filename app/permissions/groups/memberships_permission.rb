module Groups::MembershipsPermission

  protected

  ##
  ## FOR SELF
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

  ##
  ## FOR OTHERS
  ##

  def may_list_memberships?
    current_user.may? :see_members, @group
  end

  #
  # permission for immediately removing someone from a group.
  # this is possible if there is a council, the current_user is
  # in the council, but the other user is not.
  # 
  # for most other cases, use may_create_destroy_membership_request?
  #
  def may_destroy_membership?(membership = @membership)
    group = membership.group
    user = membership.user

    group.council != group and
    current_user.may?(:admin, group) and
    user != current_user and
    !user.may?(:admin, group)
  end

  def may_edit_memberships?(group=@group)
    current_user.may? :admin, group
  end

end
