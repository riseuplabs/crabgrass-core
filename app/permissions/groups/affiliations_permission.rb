module Groups::AffiliationsPermission

  protected

  def may_create_group_committee?(group=@group)
    return false if !Conf.committees
    current_user.may?(:admin, group) and group.parent_id.nil?
  end

  # (must accept optional argument)
  def may_list_group_committees?(group = @group)
    return false if !Conf.committees
    return false if group.parent_id
    current_user.may? :see_committees, group
  end

  def may_list_group_networks?(group = @group)
    return false if !Conf.networks
    current_user.may? :see_networks, group
  end

  def may_show_affiliations?(group = @group)
    may_list_groups_networks?(group) or
    may_list_groups_committees?(group) or
    group.real_council
  end

end
