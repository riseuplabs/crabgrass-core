class User < ActiveRecord::Base

  ##
  ## CORE EXTENSIONS
  ##

  include UserExtension::Cache      # cached user data (should come first)
  include UserExtension::Users      # user <--> user
  include UserExtension::Groups     # user <--> groups
  include UserExtension::Pages      # user <--> pages
  include UserExtension::Tags       # user <--> tags
  include UserExtension::ChatChannels # user <--> chat channels
  include UserExtension::AuthenticatedUser

  ##
  ## VALIDATIONS
  ##

  include Crabgrass::Validations
  validates_handle :login

  validates_presence_of :email, :if => :should_validate_email

  before_validation :validates_receive_notifications

  def validates_receive_notifications
    self.receive_notifications = nil if ! ['Single', 'Digest'].include?(self.receive_notifications)
  end

  validates_as_email :email
  before_validation 'self.email = nil if email.empty?'
  # ^^ makes the validation succeed if email == ''

  def should_validate_email
    if Site.current
      Site.current.require_user_email
    else
      Conf.require_user_email
    end
  end

  ##
  ## NAMED SCOPES
  ##

  scope :recent, :order => 'users.created_at DESC', :conditions => ["users.created_at > ?", 2.weeks.ago ]

  # (optionally) limited to +letter+
  scope :alphabetized, lambda {|letter|
    if letter == '#'
      where('login REGEXP ?', "^[^a-z]")
    elsif letter.present?
      where(['login LIKE ?', "#{letter}%"])
    else
      {}
    end
  }

  # this is a little mysql magic to get what we want:
  # We want to sort by display_name.presence || login
  # if the display_name is NULL
  #   CONCAT is null and we get login from COALESCE
  # if the display_name is ""
  #   CONCAT gives us the login
  # if the display name is present
  #   CONCAT gives display_name + login which will sort by display name basically.
  scope :alphabetical_order, order(<<-EOSQL
      LOWER(
        COALESCE(
          CONCAT(users.display_name, users.login),
          users.login
        )
      ) ASC
    EOSQL
                                   )

  scope :named_like, lambda {|filter|
    { :conditions => ["users.login LIKE ? OR users.display_name LIKE ?",
      filter, filter] }
  }

  # select only logins
  scope :logins_only, :select => 'login'


  ##
  ## USER IDENTITY
  ##

  belongs_to :avatar, :dependent => :destroy

  validates_format_of :login, :with => /^[a-z0-9]+([-_\.]?[a-z0-9]+){1,17}$/
  before_validation :clean_names

  def clean_names
    write_attribute(:login, (read_attribute(:login)||'').downcase)

    t_name = read_attribute(:display_name)
    if t_name
      write_attribute(:display_name, t_name.gsub(/[&<>]/,''))
    end
  end

  after_save :update_name
  def update_name
    if login_changed? and !login_was.nil?
      Page.update_owner_name(self)
      Wiki.clear_all_html(self)
    end
  end

  after_destroy :kill_avatar
  def kill_avatar
    avatar.destroy if avatar
  end

  # the user's custom display name, could be anything.
  def display_name
    read_attribute('display_name').presence || login
  end

  # the user's handle, in same namespace as group name,
  # must be url safe.
  def name; login; end

  # displays both display_name and name
  def both_names
    if read_attribute('display_name').present? && read_attribute('display_name') != name
      '%s (%s)' % [display_name,name]
    else
      name
    end
  end
  alias :to_s :both_names   # used for indexing

  def cut_name
    name[0..20]
  end


  def to_param
    return login
  end

  def path
    "/#{login}"
  end

  def banner_style
    #@style ||= Style.new(:color => "#E2F0C0", :background_color => "#6E901B")
    @style ||= Style.new(:color => "#eef", :background_color => "#1B5790")
  end

  def online?
    last_seen_at > 10.minutes.ago if last_seen_at
  end

  def time_zone
    read_attribute(:time_zone) || Time.zone_default
  end

  #
  # returns this user, as a ghost.
  #
  def ghostify!
    self.update_attribute(:type, "UserGhost") # in testing environment, fails with response that `type=' is undefined method, but works fine in code itself.
    return User.find(self.id)
  end

  ##
  ## PROFILE
  ##

  has_many :profiles, :as => 'entity', :dependent => :destroy, :extend => ProfileMethods

  def profile(reload=false)
    @profile = nil if reload
    @profile ||= self.profiles.visible_by(User.current)
  end

  ##
  ## USER SETTINGS
  ##

  has_one :setting, :class_name => 'UserSetting', :dependent => :destroy

  # allow us to call user.setting.x even if user.setting is nil
  def setting_with_safety(*args); setting_without_safety(*args) or UserSetting.new; end
  alias_method_chain :setting, :safety

  def update_setting(attrs)
    if setting.id
      setting.attributes = attrs
      setting.save if setting.changed?
    else
      create_setting(attrs)
    end
  end

  # returns true if the user wants to receive
  # and email when someone sends them a page notification
  # message.
  def wants_notification_email?
    self.email.present?
  end

  ##
  ## ASSOCIATED DATA
  ##

  has_many :task_participations, :dependent => :destroy
  has_many :tasks, :through => :task_participations do
    def pending
      self.find(:all, :conditions => 'assigned == TRUE AND completed_at IS NULL')
    end
    def completed
      self.find(:all, :conditions => 'completed_at IS NOT NULL')
    end
    def priority
      self.find(:all, :conditions => ['due_at <= ? AND completed_at IS NULL', 1.week.from_now])
    end
  end

  has_many :posts, :dependent => :destroy

  has_many :notices, :dependent => :destroy

  after_destroy :destroy_requests
  def destroy_requests
    Request.destroy_for_user(self)
  end

  # returns the rating object that this user created for a rateable
  def rating_for(rateable)
    rateable.ratings.by_user(self).first
  end

  # returns true if this user rated the rateable
  def rated?(rateable)
    return false unless rateable
    rating_for(rateable) ? true : false
  end


  ##
  ## PERMISSIONS
  ##

  # keyring_code used by castle_gates and pathfinder
  def keyring_code
    "%04d" % "1#{id}"
  end

  # all codes of the entities I have access to:
  def access_codes
    codes = [0] # public
    return codes if new_record?
    codes << keyring_code.to_i # me
    codes.concat friend_id_cache.map{|id| "7#{id}".to_i} # friends
    codes.concat all_group_id_cache.map{|id| "8#{id}".to_i} # peers
    codes.concat peer_id_cache.map{|id| "9#{id}".to_i} # groups
  end

  # Returns true if self has the specified level of access on the protected thing.
  # Thing may be anything that defines the method:
  #
  #    has_access!(access_sym, user)
  #
  # Currently, this includes Page and Group.
  #
  # this method gets called a lot (ie current_user.may?(:admin,@page)) so
  # we in-memory cache the result.
  #
  def may?(perm, protected_thing)
    begin
      may!(perm, protected_thing)
    rescue PermissionDenied
      false
    end
  end

  def may!(perm, protected_thing)
    return false if protected_thing.nil?
    return true if protected_thing.new_record?
    key = "#{protected_thing.to_s}"
    if @access and @access[key] and !@access[key][perm].nil?
      result = @access[key][perm]
    else
      result = protected_thing.has_access!(perm, self) rescue false
      # has_access? might call clear_access_cache, so we need to rebuild it
      # after it has been called.
      @access ||= {}
      @access[key] ||= {}
      @access[key][perm] = result
    end
    result or raise PermissionDenied.new("Permission denied!")
  end

  #
  # zeros out the in-memory page access cache. generally, this is called for
  # you, but must be called manually in the case where access was via a
  # group and that group loses page access.
  #
  def clear_access_cache
    @access = nil
  end

  # Migrate permissions from pre-CastleGates databases to CastleGates.
  # Called from cg:upgrade:user_permissions task.
  def migrate_permissions!
    # get holders
    print '.' if id % 10 == 0
    public_holder = CastleGates::Holder[:public]
    friends_holder = CastleGates::Holder[associated(:friends)]
    peers_holder = CastleGates::Holder[associated(:peers)]

    public_gates  = profiles.public.to_gates
    private_gates = profiles.private.to_gates
    friends_gates = (private_gates + public_gates).uniq
    set_access! public_holder => public_gates
    set_access! friends_holder => friends_gates
    if profiles.private.peer?
      set_access! peers_holder => friends_gates
    else
      set_access! peers_holder => public_gates
    end

  end


  acts_as_extensible
end
