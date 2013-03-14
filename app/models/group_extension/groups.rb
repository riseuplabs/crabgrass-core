#
# Module that extends Group behavior.
#
# Handles all the group <> group relationships
#
module GroupExtension::Groups

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods

    base.instance_eval do

      has_many :federatings, :dependent => :destroy
      has_many :networks, :through => :federatings
      belongs_to :council, :class_name => 'Group', :dependent => :destroy

      # Committees are children! They must respect their parent group.
      # This uses crabgrass_acts_as_tree, which allows callbacks.
      acts_as_tree(
        :order => 'name',
        :after_add => :org_structure_changed,
        :after_remove => :org_structure_changed
      )
      alias_method :committees, :children

      has_many :real_committees,
        :foreign_key => 'parent_id',
        :class_name => 'Committee',
        :conditions => {:type => 'Committee'}

    end
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

      return pagination_letters.uniq!
    end

    # Returns a list of group ids for the page namespace of every group id
    # passed in. wtf does this mean? for each group id, we get the ids
    # of all its relatives (parents, children, siblings).
    def namespace_ids(ids)
      ids = [ids] unless ids.is_a? Array
      return [] unless ids.any?
      parentids = parent_ids(ids)
      return (ids + parentids + committee_ids(ids+parentids)).flatten.uniq
    end

    # returns an array of committee ids given an array of group ids.
    def committee_ids(ids)
      ids = [ids] unless ids.instance_of? Array
      return [] unless ids.any?
      ids = ids.join(',')
      Group.connection.select_values(
        "SELECT groups.id FROM groups WHERE parent_id IN (#{ids})"
      ).collect{|id|id.to_i}
    end

    def parent_ids(ids)
      ids = [ids] unless ids.instance_of? Array
      return [] unless ids.any?
      ids = ids.join(',')
      Group.connection.select_values(
        "SELECT groups.parent_id FROM groups WHERE groups.id IN (#{ids})"
      ).collect{|id|id.to_i}
    end

    def can_have_committees?
      Conf.committees
    end

    def can_have_council?
      Conf.councils && self.can_have_committees?
    end


  end

  ##
  ## INSTANCE METHODS
  ##

  module InstanceMethods

    # Adds a new committee or makes an existing committee be the council (if
    # the make_council argument is set). No other method of adding committees
    # should be used.
    def add_committee!(committee, make_council=false)
      make_council = true if committee.council?
      committee.parent_id = self.id
      committee.parent_name_changed
      if make_council
        committee = add_council(committee)
      elsif self.council == committee
        # downgrade the council to a committee
        committee.destroy_permissions
        committee.type = "Committee"
        committee.becomes(Committee)
        self.council = nil
      end
      committee.save!

      self.org_structure_changed
      self.save!
      self.committees.reset

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
      committee.parent_id = nil
      if council_id == committee.id
        self.council = nil
        committee.type = "Committee"
      end
      committee.save!
      committee.destroy_permissions
      self.org_structure_changed
      self.save!
      self.committees.reset
    end

    public

    # returns an array of all children ids and self id (but not parents).
    # this is used to determine if a group has access to a page.
    def group_and_committee_ids
      @group_ids ||= ([self.id] + Group.committee_ids(self.id))
    end

    # returns an array of committees visible to the given user
    def committees_for(user)
      self.real_committees.with_access(user => :view)
    end

    # whenever the structure of this group has changed
    # (ie a committee or network has been added or removed)
    # this function should be called. Afterward, a save is required.
    def org_structure_changed(child=nil)
      User.clear_membership_cache(user_ids)
      self.version += 1
    end

    # overridden for Networks
    def groups() [] end

    def member_of?(network)
      network_ids.include?(network.id)
    end

    def has_a_council?
      self.council != nil
    end

    private

    def add_council(committee)
      if has_a_council?
        council.update_attribute(:type, "Committee")
      end
      committee.type = "Council"
      committee.becomes(Council)
      self.council = committee
      self.save!

      # creating a new council for a new group
      # the council members will be able to remove other members
      if self.memberships.count < 2
        committee.full_council_powers = true
      end

      return committee
    end
  end

end
