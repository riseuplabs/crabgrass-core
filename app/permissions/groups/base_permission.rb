module Groups::BasePermission

  protected

  # allow immediate destruction for groups no larger than:
  MAX_SIZE_FOR_QUICK_DESTROY_GROUP = 3

  # used from the home controller
  def may_show_group?(group = @group)
    current_user.may? :view, group
  end

  def may_edit_group?(group = @group)
    current_user.may?(:edit, group)
  end

  def may_admin_group?(group = @group)
    current_user.may?(:admin, group)
  end

  def may_create_group?(parent = @group)
    (parent.nil? || current_user.may?(:admin, parent))
  end

  def may_create_network?
    Conf.networks and logged_in?
  end

  #
  # this is for immediately destroying the group.
  # compare to: may_create_destroy_request?
  #
  def may_destroy_group?(group = @group)
    current_user.may?(:admin, group) and (
      group.committee? or group.council? or group.users.count <= MAX_SIZE_FOR_QUICK_DESTROY_GROUP
    )
  end

end
