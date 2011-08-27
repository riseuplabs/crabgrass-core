module Groups::CommitteesPermission

  protected

  def may_create_group_committee?(group=@group)
    return false if !Conf.committees
    current_user.may?(:admin, group) and group.parent_id.nil?
  end

end
