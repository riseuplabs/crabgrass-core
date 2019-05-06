#  Everything to do with user <> group relationships should be here.
#
#  "memberships" is the join table:
#    user has many groups through memberships
#    group has many users through memberships
#
#  There is only one valid way to establish membership between user and group:
#
#    group.add_user! user
#
#  Other methods should not be used!
#
#  Membership information is cached in the user table. It will get automatically
#  updated whenever membership is created or destroyed. In cases of indirect
#  membership (all_groups) the database is correctly updated but the in-memory
#  object will need to be reloaded if you want the new data.
module User::Groups
  extend ActiveSupport::Concern

  included do
    has_many :memberships, foreign_key: 'user_id',
                           class_name: 'Group::Membership',
                           dependent: :destroy,
                           before_add: :check_duplicate_memberships

    has_many :groups, foreign_key: 'user_id', through: :memberships do
      def <<(*_dummy)
        raise "don't call << on user.groups"
      end

      def delete(*records)
        super(*records)
        records.each do |group|
          group.increment!(:version)
        end
        proxy_association.owner.clear_peer_cache_of_my_peers
        proxy_association.owner.update_membership_cache
      end

      def by_visited
        order('memberships.visited_at DESC')
      end

      # groups we have visited most recently, including their parent groups.
      def recently_active(options = {})
        options[:limit] ||= 20
        grps = by_visited
               .limit(options[:limit])
               .includes(:parent)
               .to_a
        grps += grps.map(&:parent).compact
        grps.sort_by(&:name).uniq(&:name)
      end
    end

    # primary groups are:
    # (1) groups user has a direct membership in.
    # (2) committees only if the user is not also the member of the parent group
    # (3) not networks
    # 'primary groups' is useful when you want to list of the user's groups,
    # including committees only when necessary. primary_groups_and_networks is the same
    # but it includes networks in addition to just groups.
    has_many :primary_groups,
             ->(owner) { where owner.primary_groups_condition },
             class_name: 'Group',
             through: :memberships,
             source: :group

    has_many :primary_networks,
             -> { where type: 'Network' },
             class_name: 'Group',
             through: :memberships,
             source: :group

    has_many :primary_groups_and_networks,
             ->(owner) { where owner.primary_groups_and_networks_condition },
             class_name: 'Group',
             through: :memberships,
             source: :group

    # just groups and networks the user is a member of, no committees.
    has_many :groups_and_networks,
             -> { where GROUPS_AND_NETWORKS_CONDITION },
             class_name: 'Group',
             through: :memberships,
             source: :group

    serialize_as IntArray,
                 :direct_group_id_cache, :all_group_id_cache, :admin_for_group_id_cache

    initialized_by :update_membership_cache,
                   :direct_group_id_cache, :all_group_id_cache, :admin_for_group_id_cache
  end

  #
  # CONDITIONS for associations
  #
  def primary_groups_condition
    <<-EOSQL
      ( type IS NULL
        OR parent_id NOT IN (#{direct_group_id_cache.to_sql})
      )
    EOSQL
  end

  def primary_groups_and_networks_condition
    <<-EOSQL
      ( type IS NULL
        OR type = \'Network\'
        OR parent_id NOT IN (#{direct_group_id_cache.to_sql})
      )
    EOSQL
  end

  # all groups, including groups we have indirect access to even when there
  # is no membership join record. (ie committees and networks)
  def all_groups
    Group.where(id: all_group_id_cache)
  end

  # is this user a member of the group?
  # (or any of the associated groups)
  def member_of?(group)
    if group.is_a? Array
      group.detect { |g| member_of?(g) }
    elsif group.is_a? Integer
      all_group_ids.include?(group)
    elsif group.is_a? Group
      all_group_ids.include?(group.id)
    end
  end

  # is the user a direct member of the group?
  def direct_member_of?(group)
    if group.is_a? Array
      group.detect { |g| direct_member_of?(g) }
    elsif group.is_a? Integer
      group_ids.include?(group)
    elsif group.is_a? Group
      group_ids.include?(group.id)
    end
  end

  #
  # returns true if and only if the group has a council and the user is a member of it.
  #
  def council_member_of?(group)
    group.has_a_council? && direct_member_of?(group.council)
  end

  #
  # sometimes we want to restrict some activities to long term members (like destroying the group!)
  #
  def longterm_member_of?(group)
    if group.created_at > 1.week.ago
      member_of?(group)
    elsif membership = group.memberships.find_by_user_id(id)
      membership.created_at < 1.week.ago
    end
  end

  def check_duplicate_memberships(membership)
    if group_ids.include?(membership.group_id)
      raise AssociationError.new(I18n.t(:invite_error_already_member))
    end
  end

  private

  GROUPS_AND_NETWORKS_CONDITION = '(type IS NULL OR type = \'Network\')'.freeze
end
