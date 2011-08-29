module Groups::InvitesPermission

  def may_create_group_invite?(group=@group)
    current_user.may? :admin, group
  end

end
