module Groups::WikiPermission

  protected

  def may_edit_group_wiki?(group=@group)
    current_user.member_of?(group)
  end

  def may_show_group_wiki?(group=@group)
    current_user.member_of?(group) or
      @group.public_wiki
  end

end
