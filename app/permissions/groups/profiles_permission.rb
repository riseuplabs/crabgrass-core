module Groups::ProfilesPermission

  protected

  def may_edit_group_profile?(group = @group)
    current_user.may? :admin, group
  end

end
