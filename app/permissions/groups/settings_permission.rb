##
## GROUP SETTINGS
##

module Groups::SettingsPermission

  protected

  def may_show_groups_settings?(group = @group)
    current_user.may? :admin, group
  end

  def may_update_groups_settings?(group = @group)
    current_user.may? :admin, group
  end

end
