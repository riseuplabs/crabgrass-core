module Groups::CouncilsPermission

  protected

  def may_create_group_council?(group=@group)
    Conf.councils and
    group.parent_id.nil? and
    !group.real_council and
    current_user.may?(:admin, group)
  end

end
