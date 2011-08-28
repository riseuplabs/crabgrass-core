#
# this is for current_user's memberships.
# it should perhaps be called 'my_memberships'
#

module Groups::MembershipsPermission

  protected

  def may_create_group_membership?(group=@group)
    logged_in? and
    group and
    (current_user.may?(:admin, group) or current_user.may?(:join, group)) and
    !current_user.member_of?(group)
  end

  def may_destroy_group_membership?(group = @group)
    logged_in? and
    current_user.direct_member_of?(group) and
    (group.network? or group.users.uniq.size > 1)
  end

  def may_create_remove_user_requests?(membership = @membership)
    # TODO: fix all the issues with these requests so that voting on user removal works
    return false

    group = membership.group
    user = membership.user

    # has to have a council
    group.council != group and
    current_user.may?(:admin, group) and
    user != current_user and
    RequestToRemoveUser.for_user(user).for_group(group).blank?
  end
end
