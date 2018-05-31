class GroupPolicy < ApplicationPolicy

  # allow immediate destruction for groups no larger than:
  MAX_SIZE_FOR_QUICK_DESTROY_GROUP = 3

  # used from the home and pages controller
  def show?
    user.may? :view, record
  end

  def edit?
    user.may?(:edit, record)
  end

  def admin?
    user.may?(:admin, record)
  end

  # TODO: we need to investigate group creation a bit.
  # record may be a group or network.
  def create?
    return false if record.network? && !Conf.networks
    user.may?(:admin, record)
  end

  #
  # this is for immediately destroying the group.
  # compare to: may_create_destroy_request?
  #
  def destroy?
    user.may?(:admin, record) and (
      record.committee? or record.council? or record.users.count <= MAX_SIZE_FOR_QUICK_DESTROY_GROUP
    )
  end
  #
  # may user join the group immediately?
  #
  # for requests, see may_create_join_request?
  #
  def may_join_group?
    logged_in? and
      record and
      (user.may?(:admin, record) or user.may?(:join, record)) and
      !user.direct_member_of?(record)
  end

  #
  # may the current user add someone directly to a group without sending them an invite first?
  #
  # currently, this is possible only if the group is a committee and the user is in the parent group.
  #
  def may_create_membership?
    logged_in? and
      record and
      record.parent and
      user.may?(:admin, record) and
      ((user && user.member_of?(record.parent)) || user.nil?)
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
      user.direct_member_of?(record) and
      (record.network? or record.committee? or record.users.uniq.size > 1)
  end


  ##
  ## INDEX, SHOW
  ##

  def may_list_memberships?
    user.may? :see_members, record
  end

  ##
  ## MEMBERSHIP REQUESTS
  ##

  #
  # may request to join the group?
  #
  def may_create_join_request?
    logged_in? and
      record and
      user.may?(:request_membership, record) and
      !user.member_of?(record)
  end

  ### former STRUCTURES PERMISSIONS

  def edit_structure?
    may_create_council? or may_create_committee? # or may_federate?
  end

  #
  # A group member can create a council for a group during the group's first week,
  # but after that they can only create a request to create a council, which must be approved.
  #
  def may_create_council?
    record.class.can_have_council? and
      !record.has_a_council? and
      user.may?(:admin, record) and
      (record.recent? || record.single_user?)
  end

  def may_create_committee?
    record.class.can_have_committees? and
      user.may?(:admin, record)
  end

  def may_list_group_committees?
    return false unless Conf.committees
    return false if record.parent_id
    user.may? :see_committees, record
  end

  def may_list_group_networks?
    Conf.networks and
      record.normal? and
      user.may? :see_networks, record
  end

  def may_show_affiliations?
    may_list_group_networks? or
      may_list_group_committees? or
      record.has_a_council?
  end

  #
  # request to destroy the group
  #
  def may_create_destroy_request?
    RequestToDestroyOurGroup.may_create?(group: record, current_user: user)
  end

  #
  # request to create a council
  #
  def may_create_council_request?
    RequestToCreateCouncil.may_create?(group: record, current_user: user)
  end

end
