module Groups::SettingsPermission

  protected

  def may_show_group_settings?(group = @group) #doesn't seem to be used anywhere
    current_user.may? :admin, group
  end

  def may_edit_group_settings?(group = @group) #doesn't seem to be used anywhere
    current_user.may? :admin, group
  end

end
