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
class Federating < ActiveRecord::Base
  # required
  belongs_to :group
  belongs_to :network, :class_name => 'Group'

  validates_presence_of :group_id
  validates_presence_of :network_id

  validate :group_is_not_network
  validate :group_is_not_network_committee


  # optional
  belongs_to :council, :class_name => 'Group'
  belongs_to :delegation, :class_name => 'Group'

  scope :alphabetized_by_group, :joins => :group, :order => 'groups.full_name ASC, groups.name ASC'

  alias :entity :group

  protected

  def group_is_not_network
    if group.network?
      errors.add(:group, "may not be a network.")
    end
  end

  def group_is_not_network_committee
    if group.committee? && group.parent.network?
      errors.add(:group, "may not be a networks committee.")
    end
  end
end
