=begin

  PAGE RELATIONSHIP TO USERS

=end

module Page::Users

  def self.included(base)
    base.instance_eval do

      before_create :set_user
      after_validation :ensure_owner, on: :create
      before_save :denormalize

      belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
      belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by_id'
      has_many :user_participations,
        class_name: 'User::Participation',
        dependent: :destroy,
        inverse_of: :page
      has_many :users, through: :user_participations do
        def with_access
          where('access IS NOT NULL')
        end
        def contributed
          where('changed_at IS NOT NULL')
        end
      end

      after_save :reset_users
    end

  end

  ##
  ## CALLBACKS
  ##

  protected

  def ensure_owner
    if Conf.ensure_page_owner?
      self.owner ||= default_owner if default_owner.present?
    end
    return true
  end

  #
  # pick the default owner based on participations and created_by
  #
  # This is used during page initialization. The page may not
  # have been saved yet and we rely on the cached group_participations.
  # So please do not rewrite this to sth. that tries to load the group from db.
  #
  def default_owner
    if gp = group_participations.detect{|gp|gp.access == ACCESS[:admin]}
      gp.group
    else
      self.created_by
    end
  end

  # denormalize hack follows:
  def denormalize
    if updated_by_id_changed?
      self.updated_by_login = (updated_by.login if updated_by)
    end
    true
  end

  # when we save, we want the users association to relect whatever changes have
  # been made to user_participations
  def reset_users
    self.users.reset
    true
  end

  def set_user
    if User.current or self.created_by
      self.created_by ||= User.current
      self.created_by_login = self.created_by.login
      self.updated_by       = self.created_by
      self.updated_by_login = self.created_by.login
    end
    true
  end

  ##
  ## USERS
  ##

  public

  #
  # timestamp of the last visit of a user
  #
  def last_visit_of(user)
    return nil unless user.real?
    user_participations.where(user_id: user).first.try.viewed_at
  end

  # used for sphinx index
  # e: why not just use the normal user_ids()? i guess the assumption is that
  # user_participations will always be already loaded if we are saving the page.
  def user_ids
    user_participations.collect{|upart|upart.user_id}
  end

  # like users.with_access, but uses already included data
  #def users_with_access
  #  user_participations.collect{|part| part.user if part.access }.compact
  #end

  # A contributor has actually modified the page in some way. A participant
  # simply has a user_participation record, maybe they have never even seen
  # the page.
  # This method is like users.contributed, but uses already included data
  #def contributors
  #  user_participations.collect{|part| part.user if part.changed_at }.compact
  #end

  ##
  ## USER PARTICIPATION
  ##

  # returns true if +user+ has contributed to the page
  def contributor?(user)
    participation_for_user(user).try(:changed_at).present?
  end

  def unread_by?(user)
    part = participation_for_user(user)
    part and not part.viewed?
  end

  # Returns the user participation object for +user+.
  # This method is almost always called on the current user.
  def participation_for_user(user)
    return false unless user.real?
    if new_record? or association(:user_participations).loaded?
      # if we have in-memory data for user_participations, we must use it.
      # why?
      # * participation_for_user can be called on pages that have not yet
      #   been saved.
      # * we remove the participation of a user in memory and check for access
      #   in User#may_admin_page_without
      # * Also, heck, it is faster.
      upart = user_participations.find{|p| p.user_id==user.id }
    else
      # go ahead and fetch the one record we care about.
      # We probably don't care about others anyway.
      upart = user_participations.find_by_user_id(user.id)
    end
    upart.page = self if upart
    # ^^ use the same memory for upart.page. this is really useful
    # for when @page is already loaded and the upart code changes
    # a value, like stars_count. also, it saves a bunch of extra
    # queries.
    upart
  end

  # A list of the user participations, with the following properties:
  # * sorted first by access level, second by changed_at, third by login.
  # * limited to users who have access OR changed_at
  # This uses a limited query, otherwise it takes forever on pages with many participants.
  def sorted_user_participations(options={})
    self.user_participations.
      includes(:user).
      order('access ASC, changed_at DESC').
      where('access IS NOT NULL OR changed_at IS NOT NULL')
  end


end # module

