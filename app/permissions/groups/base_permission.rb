module Groups::BasePermission

  protected

  def may_create_group?(parent = @group)
    (parent.nil? || current_user.may?(:admin, parent))
  end

  #
  # this is for immediately destroying the group.
  # compare to: may_create_destroy_request?
  #
  def may_destroy_group?(group = @group)
    current_user.may?(:admin, group) and (
      group.committee? or group.council? or group.users.count >= MAX_SIZE_FOR_QUICK_DESTROY_GROUP
    )
  end

  # allow immediate destruction for groups no larger than:
  MAX_SIZE_FOR_QUICK_DESTROY_GROUP = 3

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
