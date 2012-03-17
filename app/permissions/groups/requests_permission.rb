module Groups::RequestsPermission

  protected

  #
  # list all the requests
  #
  def may_list_group_requests?(group=@group)
    current_user.may?(:admin, group)
  end

  #
  # may request to join the group?
  #
  def may_create_join_request?(group=@group)
  #def may_create_group_request?(group=@group)
    logged_in? and
    group and
    current_user.may?(:request_membership, group) and
    !current_user.member_of?(group)
    # and ensure request doesn't already exist? no, just show difft link then
  end

  #
  # request to destroy the group
  #
  def may_create_destroy_request?(group=@group)
    current_user.may?(:admin, group)
  end

  #
  # request to kick someone out of the group
  #
  def may_create_expell_request?(membership=@membership)
  #def may_create_destroy_membership_request?(group=@group)
    group = membership.group
    user = membership.user
    current_user.may?(:admin, group) and
    not RequestToRemoveUser.already_exists?(:user => user, :group => group)
  end
  
#  def may_create_remove_user_requests?(membership = @membership)
#    # TODO: fix all the issues with these requests so that voting on user removal works
#    return false
#    group = membership.group
#    user = membership.user
#    # has to have a council
#    group.council != group and
#    current_user.may?(:admin, group) and
#    user != current_user and
#    RequestToRemoveUser.for_user(user).for_group(group).blank?
#  end


end
