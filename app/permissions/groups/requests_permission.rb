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
    current_user.may?(:admin, group)
  end

end
