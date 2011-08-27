module Groups::BasePermission

  protected

  def may_create_group?(parent = @group)
    (parent.nil? || current_user.may?(:admin, parent))
  end

  def may_destroy_group?(group = @group)
    # has a council
    if group.council != group and group.council.users.size == 1
      current_user.may?(:admin, group)
      # disabled until release 0.5.1
      false
    elsif group.council == group
      # no council
      group.users.size == 1 and
        current_user.member_of?(group)
    end
  end

  def may_edit_group?(group = @group)
    current_user.may?(:admin, group)
  end

  # for now, same as edit, but might not be in the future.
  def may_admin_group?
    current_user.may?(:admin, @group)
  end

  def may_create_network?
    Conf.networks and logged_in?
  end

  ##
  ## GROUP FEATURED PAGES
  ##
  def may_edit_featured_pages?(group = @group)
    group and current_user.may?(:admin, group)
  end

  ##
  ## GROUP MENU ITEMS
  ##
  def may_edit_menu?(group = @group)
    group and
    current_user.may?(:admin, group) and
    group == Site.current.network
  end

  ##
  ## ORGANIZATIONAL PERMISSIONS
  ##

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
    may_list_group_networks?(group) or
    may_list_group_committees?(group) or
    group.real_council
  end

  ##
  ## PERMISSIONS
  ##

  alias_method :may_list_group_permissions?, :may_admin_group?
  alias_method :may_edit_group_permissions?, :may_admin_group?

  ##
  ## EXTRA
  ##

  def may_create_group_page?(group=@group)
    logged_in? and group and current_user.member_of?(group)
  end

  def may_edit_appearance?(group=@group)
    current_user.may?(:admin,group)
  end


end
