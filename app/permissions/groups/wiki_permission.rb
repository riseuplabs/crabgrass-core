module Groups::WikiPermission

  protected

  def may_edit_group_wiki?(group=@group)
    current_user.member_of?(group)
  end

  def may_show_group_wiki?(group=@group)
    @wiki.nil? && group.public_wiki or
    @wiki == group.public_wiki or
    current_user.member_of?(group)
  end

  alias_method :may_create_group_wiki?, :may_edit_group_wiki?

end
