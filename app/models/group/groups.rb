#
# Module that extends Group behavior.
#
# Handles all the group <> group relationships
#
module Group::Groups
  extend ActiveSupport::Concern

  included do
    has_many :federatings, dependent: :destroy
    has_many :networks, through: :federatings
    belongs_to :council, class_name: 'Group'

    # Committees are children! They must respect their parent group.
    belongs_to :parent, class_name: 'Group',
                        inverse_of: :children
    has_many :children, -> { order 'name' },
             class_name: 'Group',
             foreign_key: :parent_id,
             after_add: :org_structure_changed,
             after_remove: :org_structure_changed,
             dependent: :destroy,
             inverse_of: :parent
    alias_method :committees, :children

    has_many :real_committees, -> { where type: 'Committee' },
             foreign_key: 'parent_id',
             class_name: 'Committee'
  end

  ##
  ## CLASS METHODS
  ##

  module ClassMethods
    def pagination_letters_for(groups)
      pagination_letters = []
      groups.each do |g|
        pagination_letters << g.full_name.first.upcase if g.full_name
        pagination_letters << g.name.first.upcase if g.name
      end

      pagination_letters.uniq!
    end

    # Returns a list of group ids for the page namespace of every group id
    # passed in. wtf does this mean? for each group id, we get the ids
    # of all its relatives (parents, children, siblings).
    def namespace_ids(ids)
      ids = [ids] unless ids.is_a? Array
      return [] unless ids.any?
      parentids = parent_ids(ids)
      (ids + parentids + committee_ids(ids + parentids)).flatten.uniq.compact
    end

    # returns an array of committee ids given an array of group ids.
    def committee_ids(ids)
      Group.where(parent_id: ids).pluck(:id)
    end

    def parent_ids(ids)
      Group.where(id: ids).pluck(:parent_id).compact
    end

    def can_have_committees?
      Conf.committees
    end

    def can_have_council?
      Conf.councils && can_have_committees?
    end
  end

  ##
  ## INSTANCE METHODS
  ##

  # Adds a new committee or makes an existing committee be the council (if
  # the make_council argument is set). No other method of adding committees
  # should be used.
  def add_committee!(committee, make_council = false)
    make_council = true if committee.council?
    committee.parent = self
    committee.parent_name_changed
    if make_council
      committee = add_council(committee)
    elsif council == committee
      # downgrade the council to a committee
      committee.destroy_permissions
      committee.type = 'Committee'
      committee.becomes(Committee)
      self.council = nil
    end
    committee.save!

    org_structure_changed
    save!
    committees.reset

    # make sure we actually have the right class.
    Group.find(committee.id).create_permissions
  end

  def add_council!(council)
    add_committee!(council, true)
  end

  protected

  # Removes a committee. No other method should be used.
  # We use this when destroying the committee - do not
  # use it on its own as you'll have a committee without
  # a group afterwards.
  def remove_committee!(committee)
    committee.destroy_permissions
    committee.parent_id = nil
    if council_id == committee.id
      self.council = nil
      committee.type = 'Committee'
    end
    committee.save!
    org_structure_changed
    save!
    committees.reset
  end

  public

  # returns an array of all children ids and self id (but not parents).
  # this is used to determine if a group has access to a page.
  def group_and_committee_ids
    @group_ids ||= ([id] + Group.committee_ids(id))
  end

  # returns an array of committees visible to the given user
  def committees_for(user)
    real_committees.with_access(user => :view).distinct
  end

  # whenever the structure of this group has changed
  # (ie a committee or network has been added or removed)
  # this function should be called. Afterward, a save is required.
  def org_structure_changed(_child = nil)
    User.clear_membership_cache(user_ids)
    self.version += 1
  end

  # overridden for Networks
  def groups
    []
  end

  def member_of?(network)
    network_ids.include?(network.id)
  end

  def has_a_council?
    council != nil
  end

  private

  def add_council(committee)
    council.update_attribute(:type, 'Committee') if has_a_council?
    committee.type = 'Council'
    self.council = committee
    save!

    # creating a new council for a new group
    # the council members will be able to remove other members
    committee.full_council_powers = true if memberships.count < 2

    committee
  end
end
