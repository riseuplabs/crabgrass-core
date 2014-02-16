#
#
# Everything to do with user <> user relationships should be here.
#
# "relationships" is the join table:
#    user has many users through relationships
#
module UserExtension::Users

  def self.included(base)

    base.send :include, InstanceMethods

    base.instance_eval do
      serialize_as IntArray, :friend_id_cache, :foe_id_cache

      initialized_by :update_contacts_cache,
        :friend_id_cache, :foe_id_cache

      ##
      ## PEERS
      ##

      has_many :peers,
        :class_name => 'User',
        :counter_sql => 'SELECT count(*) FROM users WHERE users.id IN (#{peer_id_cache.to_sql})' do
        # overwrites ActiveRecord::Associations::HasManyAssociation#construct_scope
        # to specify the entire conditions without using :finder_sql
        def construct_scope
          { :find => {
              :conditions => "users.id IN (#{@owner.peer_id_cache.to_sql})",
              :readonly => true,
              :order => @reflection.options[:order],
              :limit => @reflection.options[:limit],
              :include => @reflection.options[:include]
            },
            :create => {}
          }
        end
      end

      # same as results as user.peers, but chainable with other named scopes
      scope(:peers_of, lambda do |user|
        {:conditions => ['users.id in (?)', user.peer_id_cache]}
      end)

      ##
      ## USER'S STATUS / PUBLIC WALL
      ##

      has_one :wall_discussion, :as => :commentable, :dependent => :destroy, :class_name => "Discussion"

      before_destroy :save_relationships
      attr_reader :peers_before_destroy, :contacts_before_destroy

      ##
      ## RELATIONSHIPS
      ##

      has_many :relationships, :dependent => :destroy do
        def with(user) find_by_contact_id(user.id) end
      end

      has_many :discussions, :through => :relationships, :order => 'discussions.replied_at DESC'
      has_many :contacts,    :through => :relationships

      has_many :friends, :through => :relationships, :conditions => "relationships.type = 'Friendship'", :source => :contact do
        def most_active(options = {})
          options[:limit] ||= 13
          max_visit_count = find(:first, :select => 'MAX(relationships.total_visits) as id').id || 1
          select = "users.*, " + quote_sql([MOST_ACTIVE_SELECT, 2.week.ago.to_i, 2.week.seconds.to_i, max_visit_count])
          find(:all, :limit => options[:limit], :select => select, :order => 'last_visit_weight + total_visits_weight DESC')
        end
      end

      # same result as user.friends, but chainable with other named scopes
      scope(:friends_of, lambda do |user|
        {:conditions => ['users.id in (?)', user.friend_id_cache]}
      end)

      scope(:friends_or_peers_of, lambda do |user|
        {:conditions => ['users.id in (?)', user.friend_id_cache + user.peer_id_cache]}
      end)

      # neither friends nor peers
      # used for autocomplete when we preloaded the friends and peers
      scope(:strangers_to, lambda do |user|
        {:conditions => ['users.id NOT IN (?)',
          user.friend_id_cache + user.peer_id_cache + [user.id]]}
      end)

      ##
      ## CACHE
      ##

      serialize_as IntArray, :friend_id_cache, :foe_id_cache, :peer_id_cache
      initialized_by :update_contacts_cache, :friend_id_cache, :foe_id_cache
      initialized_by :update_membership_cache, :peer_id_cache

      # this seems to be the only way to override the A/R created methods.
      # new accessor defined in user_extension/cache.rb
      remove_method :friend_ids
      #remove_method :foe_ids
      #remove_method :peer_ids
    end
  end

  module InstanceMethods

    ##
    ## STATUS / PUBLIC WALL
    ##

    # returns the users current status by returning their latest status_posts.body
    def current_status
      @current_status ||= self.wall_discussion.posts.find(:first, :conditions => {'type' => 'StatusPost'}, :order => 'created_at DESC').body rescue ""
    end

    ##
    ## RELATIONSHIPS
    ##

    # Creates a relationship between self and other_user. This should be the ONLY
    # way that contacts are created.
    #
    # If type is :friend or "Friendship", then the relationship from self to other
    # user will be one of friendship.
    #
    # This method can be used to either add a new relationship or to update an
    # an existing one
    #
    # RelationshipObserver creates a new Discussion that is shared between the two relationship objects
    #
    # RelationshipObserver creates a new FriendActivity when a friendship is created.
    # As a side effect, this will create a profile for 'self' if it does not
    # already exist.
    def add_contact!(other_user, type=nil)
      type = 'Friendship' if type == :friend

      unless relationship = other_user.relationships.with(self)
        relationship = Relationship.new(:user => other_user, :contact => self)
      end
      relationship.type = type
      relationship.save!

      unless relationship = self.relationships.with(other_user)
        relationship = Relationship.new(:user => self, :contact => other_user)
      end
      relationship.type = type
      relationship.save!

      self.relationships.reset
      self.contacts.reset
      self.friends.reset
      self.update_contacts_cache

      other_user.relationships.reset
      other_user.contacts.reset
      other_user.friends.reset
      other_user.update_contacts_cache

      return relationship
    end

    # this should be the ONLY way contacts are deleted
    def remove_contact!(other_user)
      if self.relationships.with(other_user)
        self.contacts.delete(other_user)
        self.update_contacts_cache
      end
      if other_user.relationships.with(self)
         other_user.contacts.delete(self)
         other_user.update_contacts_cache
      end
    end

    # ensure a relationship between this and the other user exists
    # add a new post to the private discussion shared between this and the other_user.
    #
    # +in_reply_to+ is an optional argument for the post that this new post
    # is replying to.
    #
    # currently, this is not stored, but used to generate a more informative
    # notification on the user's wall.
    #
    def send_message_to!(other_user, body, in_reply_to = nil)
      relationship = self.relationships.with(other_user) || self.add_contact!(other_user)
      discussion = relationship.get_or_create_discussion

      if in_reply_to
        if in_reply_to.user_id == self.id
          # you cannot reply to oneself
          in_reply_to = nil
        elsif in_reply_to.user_id != other_user.id
          # we should never get here normally, this is just a sanity check
          raise ErrorMessage.new("Ugh. The user and the post you are replying to don't match.")
        end
      end

      discussion.increment_unread_for!(other_user)
      post = discussion.posts.create do |post|
        post.body = body
        post.user = self
        post.in_reply_to = in_reply_to
        post.type = "PrivatePost"
        post.recipient = other_user
      end
      post
    end


    def stranger_to?(user)
      !peer_of?(user) and !contact_of?(user)
    end

    def peer_of?(user)
      id = user.instance_of?(Integer) ? user : user.id
      peer_id_cache.include?(id)
    end

    def friend_of?(user)
      id = user.instance_of?(Integer) ? user : user.id
      friend_id_cache.include?(id)
    end
    alias :contact_of? :friend_of?

    def relationship_to(user)
      relationships_to(user).first
    end

    def relationships_to(user)
      return :stranger unless user

      @relationships_to_user_cache ||= {}
      @relationships_to_user_cache[user.login] ||= get_relationships_to(user)
      @relationships_to_user_cache[user.login].dup
    end

    def get_relationships_to(user)
      ret = []
      ret << :friend   if friend_of?(user)
      ret << :peer     if peer_of?(user)
  #   ret << :fof      if fof_of?(user)
      ret << :stranger
      ret
    end

    ##
    ## PERMISSIONS
    ##

    def may_show_status_to?(user)
      return true if user==self
      return true if friend_of?(user) or peer_of?(user)
      false
    end

  end # InstanceMethods

  private

  MOST_ACTIVE_SELECT = '((UNIX_TIMESTAMP(relationships.visited_at) - ?) / ?) AS last_visit_weight, (relationships.total_visits / ?) as total_visits_weight'

  def save_relationships
    @peers_before_destroy = peers.dup
    @contacts_before_destroy = contacts.dup
  end
end
