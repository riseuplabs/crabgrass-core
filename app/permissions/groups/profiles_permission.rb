module Groups::ProfilesPermission

  protected

  def may_edit_groups_profile?(group = @group)
    current_user.may? :admin, group
  end

end
