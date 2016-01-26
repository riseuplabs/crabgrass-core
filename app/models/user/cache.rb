=begin

Caching IDs

The idea here is that every user in a social networking universe
has a lot of relationships to other entities that might be expensive
to discover. For example, a list of all your peers or a list of all
groups you have direct or indirect access to. So, we cache it, in
the form of serialized arrays of integers corresponding to the ids of the
foreign relationships.

If you are paying attention, you will realize this is stupid. A couple reasons
why it is not:

  (1) by using compressed integers for serialization, we can actually store
      a lot of ids without taking up too much space.
  (2) it is much faster to deserialize a big array of integers than it is
      to join in another table or make an extra query.

In many cases, all we *want* are the ids, since this is sufficient
to test membership and to display name and avatar (if ever get around
to creating a memcached for users and groups that stores [id,name,avatar_id]).

Also, we make a lot of queries of the form "group_id IN (1,2,3,4)".
This is fast, according to the mysql manual:

   If all values are constants, they are evaluated according to
   the type of expr and sorted. The search for the item then is
   done using a binary search. This means IN is very quick if
   the IN value list consists entirely of constants.

This suggests that if we stored the ids caches pre-sorted, it would be
slightly faster.

As a handy bit of fun, if any of these ids caches changes, we increment
the user's version. This can be then used to easily expire caches which
use these values.

Columns
--------

  version -- increments when any of the id caches are changed

  id caches -- there are many columns to cache our relationships,
    because they are used very frequently and take time to calculate.
    The names of the cache attributes end with "_cache".

=end

module User::Cache
  extend ActiveSupport::Concern


  # For groups and users we have two cache keys:
  # * the version based for relationships of the user.
  # * the normal one based on updated_at for the user itself
  #
  # So for example a users own top menu is cached based on
  # the version cache_key so it refreshes when one of the
  # users groups changes.
  #
  # The display of a different user inside that top menu is
  # based on that users normal cache key. It changes when the
  # other user itself changes.
  def version_cache_key
    if new_record?
      cache_key
    else
      "#{self.class.model_name.cache_key}/#{id}-#{version}"
    end
  end


  #
  # friendly access, in a more railsy form
  #

  def group_ids();           direct_group_id_cache;    end
  def all_group_ids();       all_group_id_cache;       end
  def admin_for_group_ids(); admin_for_group_id_cache; end
  def peer_ids();            peer_id_cache;            end
  def friend_ids();          friend_id_cache;          end
  def foe_ids();             foe_id_cache;             end
  def tag_ids();             tag_id_cache;             end

  # Be careful with this method: it is called any time a Membership
  # object is created or destroyed, and it is also called any time
  # read_attribute(*_group_id_cache) is nil. Therefore, we better
  # set the id caches to non-nil in this method unless we want to
  # recurse forever.
  def update_membership_cache(membership=nil)
    clear_access_cache
    direct, all, admin_for = get_group_ids
    peer = get_peer_ids(direct)
    update_attributes version: (version||-1) +1, # this fixes if version is nil, but probably we should get at the root of that.
      direct_group_id_cache: direct,
      all_group_id_cache: all,
      admin_for_group_id_cache: admin_for,
      peer_id_cache: peer
  end

  #
  # When our membership changes, we need to clear the peer cache of all
  # the users who might have their peer info change. To do so, this method
  # must be called in two places:
  #   1) after a new membership is created
  #   2) before a membership is destroyed
  #
  def clear_peer_cache_of_my_peers(membership=nil)
    if peer_id_cache.any?
      User.where(id: peer_id_cache).update_all(peer_id_cache: nil)
    end
  end

  def increment_group_version(membership)
    membership.group.increment!(:version)
  end

  #
  # This should be called if a change in relationships has potentially
  # invalidated the cache. For example, adding or removing a commmittee.
  #
  def clear_cache
    # UPGRADE: use update_columns from rails4 on:
    User.where(id: self).update_all tag_id_cache: nil,
      direct_group_id_cache: nil,
      foe_id_cache: nil,
      peer_id_cache: nil,
      friend_id_cache: nil,
      all_group_id_cache: nil,
      admin_for_group_id_cache: nil
    write_attribute(:tag_id_cache, nil)
    write_attribute(:foe_id_cache, nil)
    write_attribute(:peer_id_cache, nil)
    write_attribute(:friend_id_cache, nil)
    write_attribute(:direct_group_id_cache, nil)
    write_attribute(:all_group_id_cache, nil)
    write_attribute(:admin_for_group_id_cache, nil)
    self.clear_access_cache
  end

  # called whenever an empty self.friend_id_cache is accessed
  # or directly when a new contact is added
  def update_contacts_cache()
    friend,foe = get_contact_ids
    update_attributes version: (version||-1) +1, # this fixes if version is nil, but probably we should get at the root of that.
      friend_id_cache: friend,
      foe_id_cache: foe
  end

  # include direct memberships, committees, and networks
  def get_group_ids
    if self.id
      # this can be called from inside the
      #   user.groups.recently_active.with_member(current_user)
      # association.
      # This causes self.groups to include the memberships join twice
      # I think this is a rails bug
      # So we use the memberships instead.
      # TODO: UPGRADE: check if this is fixed for self.groups.
      # (otherwise People::HomeControllerTest will fail)
      direct = self.memberships.pluck(:group_id)
    else
      direct = []
    end
    if direct.any?
      committee = Group.where(type: 'Committee', parent_id: direct).pluck(:id)
      network = Group::Network.
        joins(:federatings).
        where(federatings: {group_id: direct}).
        pluck(:id)
      if network.any?
        # we still have networks inside networks on the live server
        network += Group::Network.
          joins(:federatings).
          where(federatings: {group_id: network}).
          pluck(:id)
        committee += Group.where(type: 'Committee', parent_id: network).pluck(:id)
      end
      # admin for the own groups where either one is a member of the council or
      # there is no council - so the council_id is nil
      # TODO: isn't this missing the groups where one is only a member of the
      # council?
      admin_for = Group.where(id: (direct + committee + network)).
        where(council_id: (direct + [nil])).
        pluck(:id)
    else
      committee, network, admin_for = [],[],[]
    end
    direct = direct.map{|id| id.to_i}.uniq
    all = (direct + committee + network).map{|id|id.to_i}.uniq
    admin_for = admin_for.map{|id| id.to_i}.uniq
    [direct, all, admin_for]
  end

  def get_peer_ids(group_ids)
    return [] unless self.id && group_ids.present?
    # Exclude large groups from calculating peer relationships
    group_ids -= Group.large.pluck(:id)
    ids = User.joins(:memberships).
      where(memberships: {group_id: group_ids}).
      pluck('DISTINCT users.id')
    ids - [self.id]
  end

  def get_contact_ids()
    return [[],[]] unless self.id
    foe = [] # no foes yet.
    friend = self.friends.pluck(:id)
    [friend,foe]
  end

  def update_tag_cache
    # TODO: acts_as_taggable_on includes the user_id in every tagging,
    # thus making it easy to find all the tags you have made. maybe this is
    # what we should return here instead?
    if self.id
      participation_join = <<-EOSQL
          INNER JOIN user_participations
          ON taggings.taggable_id = user_participations.page_id
      EOSQL
      ids = ActsAsTaggableOn::Tagging.joins(participation_join).
        where(taggable_type: 'Page').
        where("user_participations.user_id = #{id}").
        pluck(:tag_id)
    else
      ids = []
    end
    update_attributes version: version.to_i + 1, tag_id_cache: ids
  end

  def clear_tag_cache
    self.class.clear_tag_cache([self.id])
  end

  module ClassMethods

    # takes an array of user ids and NULLs out the membership cache
    # of those users. however, the peer cache is not NULLed.
    def clear_membership_cache(ids)
      return unless ids.any?
      User.where(id: ids).update_all direct_group_id_cache: nil,
        all_group_id_cache: nil,
        admin_for_group_id_cache: nil
    end

    #
    # should be called whenever a user partipation is added or
    # the tags have changed.
    #
    def clear_tag_cache(user_ids)
      User.where(id: user_ids).update_all tag_id_cache: nil
    end

    # Takes an array of user ids and increments the version of all these
    # users. This should be called when something has changed for these users
    # that might invalidate something they have cached in their dashboard.
    # For example, when the name of a group they are part of has changed.
    # This method does not need to be called when membership is changed, the
    # version increment for that is already handled elsewhere.
    def increment_version(ids)
      return unless ids.any?
      self.where(id: ids).update_all('version = version+1')
    end

    ## serialize_as
    ## ---------------------------------
    ##
    ## usage:
    ##
    ## class Tree < ActiveRecord::Base
    ##   serialize_as IntArray, :branches, :roots
    ## end
    ##
    ## In this case, the column 'branches' will be serialized and unserialized
    ## using the IntArray.to_s and IntArray.new methods (respectively).
    ##
    ## It would be cool if I made this into a plugin, but then again, a lot
    ## of things would be cool.
    ##
    def serialize_as(klass, *keywords)
      for word in keywords
        word = word.id2name
        module_eval <<-"end_eval"
            def #{word}=(value)
              @#{word} = #{klass}.new(value)
              write_attribute('#{word}', @#{word}.to_s)
            end
            def #{word}
              @#{word} ||= #{klass}.new( read_attribute('#{word}') )
            end
        end_eval
      end
    end

    ## initialized_by
    ## ---------------------------------
    ##
    ## usage:
    ##
    ## class Tree < ActiveRecord::Base
    ##   initialized_by :my_method, :my_attribute
    ## end
    ##
    ## In this case, my_method() will be called each time my_attribute()
    ## is accessed if my_attribute is nil.
    ##
    def initialized_by(method, *attributes)
      method = method.id2name
      for attribute in attributes
        attribute = attribute.id2name
        module_eval <<-"end_eval"
            alias_method :#{attribute}_without_initialize, :#{attribute}
            def #{attribute}
              self.#{method}() if read_attribute('#{attribute}').nil?
        #{attribute}_without_initialize()
            end
        end_eval
      end
    end
  end # end ClassMethods

end
