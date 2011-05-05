module InvitesPermission

  def may_index_invites?(group=@group)
    may_edit_group?(group)
  end
end
