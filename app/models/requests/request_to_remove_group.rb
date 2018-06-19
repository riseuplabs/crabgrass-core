#
# A request to remove a group from a network.=
#
#   recipient: the network that has the group as a memeber
# requestable: the group to be removed
#  created_by: person in network who wants to remove the group
#

class RequestToRemoveGroup < Request
  validates_format_of :recipient_type,   with: /\AGroup\z/
  validates_format_of :requestable_type, with: /\AGroup\z/

  alias_attr :network, :recipient
  alias_attr :group,  :requestable

  def self.existing(options)
    pending.with_requestable(options[:group]).for_recipient(options[:network]).first
  end

  def self.for_membership(membership)
    with_requestable(membership.group).for_recipient(membership.network)
  end

  #
  # permissions
  #

  def may_create?(current_user)
    current_user.may?(:admin, network) and
      current_user.longterm_member_of?(network)
  end

  def may_approve?(current_user)
    current_user.may?(:admin, network) and
      current_user.id != created_by_id and
      current_user.longterm_member_of?(network)
  end

  def may_destroy?(current_user)
    current_user.may?(:admin, network)
  end

  alias may_view? may_create?

  def after_approval
    network.remove_group!(group)
  end

  def description
    [:request_to_remove_group_description, {
      user: user_span(created_by),
      group: group_span(group),
      network: network_span(network)
    }]
  end

  def short_description
    [:request_to_remove_group_short, {
      group: group_span(group),
      network: network_span(network)
    }]
  end

  def icon_entity
    group
  end

end
