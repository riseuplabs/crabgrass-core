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
  # this is possible if there is a council, the current_user is
  # in the council, but the other user is not.
  # 
  # for most other cases, use may_create_expell_request?
  #
  def may_destroy_membership?(membership = @membership)
    group = membership.group
    user = membership.user

    current_user.council_member_of?(group) and
    !user.council_member_of?(group) and
    user != current_user
  end

  ##
  ## INDEX, SHOW
  ##

  def may_list_memberships?
    current_user.may? :see_members, @group
  end

  def may_edit_memberships?(group=@group)
    current_user.may? :admin, group
  end

  
  ##
  ## MEMBERSHIP REQUESTS
  ##

  #
  # for now, same as other group requests
  #
  def may_list_membership_requests?(group=@group)
    may_list_group_requests?(group)
  end
  
  #
  # may invite someone to be a member of this group?
  #
  def may_create_group_invite?(group=@group)
    # TODO: if it is an open group, admin should not be required.
    current_user.may? :admin, group
  end

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
  def may_create_expell_request?(membership=@membership)
    group = membership.group
    user = membership.user
    current_user.may?(:admin, group) and
    not RequestToRemoveUser.existing(:user => user, :group => group)
  end

end
