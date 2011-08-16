module Groups::InvitesPermission

  def may_list_groups_invites?(group=@group)
    current_user.may? :admin, group
  end

  def may_create_groups_invite?(group=@group)
    current_user.may? :admin, group
  end

  def may_edit_groups_invite?(group=@group)
    current_user.may? :admin, group
  end

  def may_destroy_groups_invite?(group=@group)
    current_user.may? :admin, group
  end

end
