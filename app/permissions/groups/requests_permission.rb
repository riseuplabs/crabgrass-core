module Groups::RequestsPermission

  protected

  def may_create_group_request?(group=@group)
    logged_in? and
    group and
    current_user.may?(:request_membership, group) and
    !current_user.member_of?(group)
    # and ensure request doesn't already exist? no, just show difft link then
  end

  def may_create_destroy_request?(group=@group)
    current_user.may?(:admin, group)
  end

  def may_list_group_requests?(group=@group)
    current_user.may?(:admin, group)
  end

end
