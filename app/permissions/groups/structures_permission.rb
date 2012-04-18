module Groups::StructuresPermission

  protected

  def may_show_group_structure?
    may_admin_group?
  end

  def may_edit_group_structure?
    may_create_council? or may_create_committee? or may_federate?
  end

  #
  # A group member can create a council for a group during the group's first week, 
  # but after that they can only create a request to create a council, which must be approved.
  #
  def may_create_council?(group = @group)
    Conf.councils and
    group.parent_id.nil? and
    !group.has_a_council? and
    current_user.may?(:admin, group) and
    group.created_at > 1.week.ago
  end

  def may_create_committee?(group = @group)
    return false if !Conf.committees
    current_user.may?(:admin, group) and group.parent_id.nil?
  end

  def may_federate?(group = @group)

  end

  def may_list_group_committees?(group = @group)
    return false if !Conf.committees
    return false if group.parent_id
    current_user.may? :see_committees, group
  end

  def may_list_group_networks?(group = @group)
    Conf.networks and
    group.normal? and
    current_user.may? :see_networks, group
  end

  def may_show_affiliations?(group = @group)
    may_list_group_networks?(group) or
    may_list_group_committees?(group) or
    group.has_a_council?
  end

end
