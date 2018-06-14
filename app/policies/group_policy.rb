class GroupPolicy < ApplicationPolicy

  # allow immediate destruction for groups no larger than:
  MAX_SIZE_FOR_QUICK_DESTROY_GROUP = 3

  # used from the home and pages controller
  def show?
    user.may?(:view, group)
  end

  def update?
    user.may?(:edit, group)
  end

  def admin?
    user.may?(:admin, group)
  end

  # TODO: we need to investigate group creation a bit.
  # group may be a group or network.
  def create?
    return false if group.network? && !Conf.networks
    user.may?(:admin, group)
  end

  #
  # this is for immediately destroying the group.
  # compare to: may_create_destroy_request?
  #
  def destroy?
    user.may?(:admin, group) and (
      group.committee? or group.council? or group.users.count <= MAX_SIZE_FOR_QUICK_DESTROY_GROUP
    )
  end

  #
  # request to destroy the group
  #
  def may_create_destroy_request?
    RequestToDestroyOurGroup.may_create?(group: group, current_user: user)
  end

  ##
  ## MEMBERSHIPS
  ##
  ## TODO: check if we can move those to memberships_policy.
  ## Not sure how this might work, because in most cases we have
  ## no membership object
  #

  ##
  ## CREATION
  ##


  # may the current user add someone directly to a group without sending them an invite first?
  #
  # currently, this is possible only if the group is a committee and the user is in the parent group.
  #
  def may_create_membership?
    logged_in? and
      group and
      group.parent and
      user.may?(:admin, group) and
      ((user && user.member_of?(group.parent)) || user.nil?)
  end

  # may user join the group immediately?
  #
  # for requests, see may_create_join_request?
  #
  def may_join_group?
    logged_in? and
      group and
      (user.may?(:admin, group) or user.may?(:join, group)) and
      !user.direct_member_of?(group)
  end

  #
  # may request to join the group?
  #
  def may_create_join_request?
    logged_in? and
      group and
      user.may?(:request_membership, group) and
      !user.member_of?(group)
  end

  ##
  ## DESTRUCTION
  ##

  #
  # may the user leave the group?
  #
  # you can leave a group if it has more than one member
  # or it is a network or committee.
  #
  def may_leave_group?
    logged_in? and
      user.direct_member_of?(group) and
      (group.network? or group.committee? or group.users.uniq.size > 1)
  end


  ##
  ## INDEX, SHOW
  ##

  def may_list_memberships?
    user.may? :see_members, group
  end

  ### former STRUCTURES PERMISSIONS

  def edit_structure?
    may_create_council? or may_create_committee?
  end

  #
  # A group member can create a council for a group during the group's first week,
  # but after that they can only create a request to create a council, which must be approved.
  # see may_create_council_request.
  #
  def may_create_council?
    group.class.can_have_council? and
      !group.has_a_council? and
      user.may?(:admin, group) and
      (group.recent? || group.single_user?)
  end

  #
  # request to create a council
  #
  # TODO: write test that covers this
  #       Is it ever used?
  def may_create_council_request?
    RequestToCreateCouncil.may_create?(group: group, current_user: user)
  end

  def may_create_committee?
    group.class.can_have_committees? and
      user.may?(:admin, group)
  end

  def may_list_group_committees?
    return false unless Conf.committees
    return false if group.parent_id
    user.may? :see_committees, group
  end

  def may_list_group_networks?
    Conf.networks and
      group.normal? and
      user.may? :see_networks, group
  end

  def may_show_affiliations?
    may_list_group_networks? or
      may_list_group_committees? or
      group.has_a_council?
  end

  def group
   record
  end

end
