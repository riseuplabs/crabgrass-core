#
# here are non-membership related group requests.
#
# for membership requests, see memberships_permission.rb
#
module Group::RequestsPermission

  protected

  #
  # request to destroy the group
  #
  def may_create_destroy_request?(group=@group)
    RequestToDestroyOurGroup.may_create?(group: group, current_user: current_user)
  end

  #
  # request to create a council
  #
  def may_create_council_request?(group=@group)
    RequestToCreateCouncil.may_create?(group: group, current_user: current_user)
  end

end
