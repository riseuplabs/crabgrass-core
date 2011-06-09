##
## GROUP PROFILE
##

module Groups::ProfilesPermission

  protected

  #
  # this is really 'may show profile editor'.
  # show the profile is covered by 'may_show?'
  #
  def may_show_profile?(group = @group)
    current_user.may? :admin, group
  end

  def may_update_profile?(group = @group)
    current_user.may? :admin, group
  end
  alias_method :may_edit_profile?, :may_update_profile?

end
