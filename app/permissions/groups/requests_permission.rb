#
# here are non-membership related group requests.
#
# for membership requests, see memberships_permission.rb
#
module Groups::RequestsPermission

  protected

  #
  # list all the requests
  #
  def may_list_group_requests?(group=@group)
    current_user.may?(:admin, group)
  end

  #
  # request to destroy the group
  #
  def may_create_destroy_request?(group=@group)
    RequestToDestroyOurGroup.may_create?(:group => group, :current_user => current_user)
  end

  #
  # request to create a council
  #
  def may_create_council_request?(group=@group)
    RequestToCreateCouncil.may_create?(:group => group, :current_user => current_user)
  end

end
