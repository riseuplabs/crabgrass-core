#
# Network
#
# A network is an aggregation of groups.
#
# Networks are like groups, except:
#
# * Networks may have both users and other groups as members
#   (the join table for groups is 'federations')
#
# * Being a member of a network does not make you the peer of the other
#   members of the network.
#
# * Networks show up under the networks tab instead of the groups tab.
#
class Group::Network < Group
  has_many :federatings, dependent: :destroy
  has_many :groups, through: :federatings

  attr_accessor :initial_member_group

  validates :initial_member_group, presence: true, unless: :persisted?
  validate :validate_initial_member_group

  after_save :add_initial_member_group

  def initial_member_group=(group)
    @initial_member_group = (group.nil? || group.is_a?(Group) ? group :
      Group.find_by_name(group))
  end

  def validate_initial_member_group
    return unless initial_member_group
    if initial_member_group.is_a? Network
      errors.add(:initial_member_group, :networks_may_not_join_nteworks.t)
    elsif initial_member_group.parent.is_a? Network
      errors.add(:initial_member_group, :network_committees_may_not_join_networks.t)
    end
  end

  def add_initial_member_group
    if @initial_member_group and !@initial_member_group.member_of? self
      add_group!(@initial_member_group)
    end
  end

  # only this method should be used for adding groups to a network
  def add_group!(group, delegation = nil)
    federatings.create!(group: group, delegation: delegation, council: council)
    group.org_structure_changed
    group.save!
    Group.increment_counter(:version, id) # in case self is not saved
    self.version += 1 # in case self is later saved
  end

  # only this method should be used for removing groups from a network
  def remove_group!(group)
    federatings.detect { |f| f.group_id == group.id }.destroy
    group.org_structure_changed
    group.save!
    Group.increment_counter(:version, id) # in case self is not saved
    self.version += 1 # in case self is later saved
  end

  # Whenever the organizational structure of this network has changed
  # this function should be called. Afterward, a save is required.
  def org_structure_changed(child = nil)
    User.clear_membership_cache(user_ids)
    self.version += 1
    groups.each do |group|
      group.org_structure_changed(child)
      group.save!
    end
  end

  def all_users
    groups.collect(&:all_users).flatten.uniq
  end
end
