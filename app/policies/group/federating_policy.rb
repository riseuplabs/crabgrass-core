class Group::FederatingPolicy < ApplicationPolicy

  # for now we do not allow directly destroying the federating
  # use a request instead.
  def destroy?
    false
  end

  def may_create_expell_request?
    group = record.group
    network = record.network
    user.may?(:admin, network) && (
      (
        !RequestToRemoveGroup.existing(group: group, network: network) &&
        RequestToRemoveGroup.may_create?(current_user: user, group: group, network: network)
      )
    )
  end

end
