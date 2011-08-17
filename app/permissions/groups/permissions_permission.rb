module Groups::PermissionsPermission

  protected

  def may_list_groups_permissions?(group = @group)
    current_user.may? :admin, group
  end

  def may_edit_groups_permissions?(group = @group)
    current_user.may? :admin, group
  end

end
