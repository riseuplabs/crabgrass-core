# A Federating holds the data relating to an association between a group and a network.
#
# Optionally, each end of a federating can specify which specific subgroup
# of the group will have membership in the council of the networks.
#
# council     -- the subgroup of the network that is a council (ie admin group)
# delegation  -- the delegation is a subgroup of the group joining the network.
#                every member of the delegation will be made a member of the
#                council.
#
# schema:
#
# create_table "federating", :force => true do |t|
#   t.integer "group_id",     :limit => 11
#   t.integer "network_id",   :limit => 11
#   t.integer "council_id",   :limit => 11
#   t.integer "delegation_id", :limit => 11
# end
#
class Group::Federating < ApplicationRecord
  self.table_name = 'federatings'

  # required
  belongs_to :group
  belongs_to :network, class_name: 'Group'

  validates :group, presence: true
  validates :network, presence: true

  validate :group_is_not_network, on: :create
  validate :group_is_not_network_committee, on: :create

  # optional
  belongs_to :council, class_name: 'Group'
  belongs_to :delegation, class_name: 'Group'

  alias entity group

  # this does not deal with users - in contrast to Memberships
  def user?
    false
  end

  protected

  def group_is_not_network
    errors.add(:group, 'may not be a network.') if group.network?
  end

  def group_is_not_network_committee
    if group.committee? && group.parent.network?
      errors.add(:group, 'may not be a networks committee.')
    end
  end
end
