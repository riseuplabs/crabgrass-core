=begin
create_table "groups", :force => true do |t|
  t.string   "name"
  t.string   "full_name"
  t.string   "summary"
  t.string   "url"
  t.string   "type"
  t.integer  "parent_id",  :limit => 11
  t.integer  "council_id", :limit => 11
  t.datetime "created_at"
  t.datetime "updated_at"
  t.integer  "avatar_id",  :limit => 11
  t.string   "style"
  t.string   "language",   :limit => 5
  t.integer  "version",    :limit => 11, :default => 0
  t.integer  "min_stars",  :limit => 11, :default => 1
  t.integer  "site_id",    :limit => 11
end

  associations:
  group.children   => groups
  group.parent     => group
  group.council    => nil or group
  group.users      => users
=end

class Group < ActiveRecord::Base

  # core group extentions
  include GroupExtension::Groups     # group <--> group behavior
  include GroupExtension::Users      # group <--> user behavior
  include GroupExtension::Featured   # this makes this group's pages featureable
  include GroupExtension::Pages      # group <--> page behavior

  attr_accessible :name, :full_name, :short_name, :summary, :language, :avatar

  # not saved to database, just used by activity feed:
  attr_accessor :created_by, :destroyed_by

  # group <--> chat channel relationship
  has_one :chat_channel

  ##
  ## FINDERS
  ##

  # find groups that do not contain the given user
  # used in autocomplete where the users groups are all preloaded
  scope :without_member, lambda { |user|
    group_ids = user.all_group_ids
    group_ids.any? ?
      {:conditions => ["NOT groups.id IN (?)", group_ids]} :
      {}
  }

  # finds groups that are of type Group (but not Committee or Network)
  scope :only_groups, :conditions => 'groups.type IS NULL'

  scope(:only_type, lambda do |*args|
    group_type = args.first.to_s.capitalize
    if group_type == 'Group'
      {:conditions => 'groups.type IS NULL'}
    elsif group_type == 'Network' and (!args[1].nil? and args[1].network_id)
      {:conditions => ['groups.type = ? and groups.id != ?', group_type, args[1].network_id] }
    else
      {:conditions => ['groups.type = ?', group_type]}
    end
  end)

  scope :groups_and_networks, :conditions => "groups.type IS NULL OR groups.type = 'Network'"

  scope :all_networks_for, lambda { |user|
    {:conditions => ["groups.type = 'Network' AND groups.id IN (?)", user.all_group_id_cache]}
  }

  # alphabetized and (optional) limited to +letter+
  scope :alphabetized, lambda {|letter|
    if letter == '#'
      where('name REGEXP ?', "^[^a-z]").alphabetical_order
    elsif letter.present?
      where(['name LIKE ?', "#{letter}%"]).alphabetical_order
    else
      alphabetical_order
    end
  }

  # this is a little mysql magic to get what we want:
  # We want to sort by display_name.presence || name
  # if the display_name is NULL
  #   CONCAT is null and we get name from COALESCE
  # if the display_name is ""
  #   CONCAT gives us the name
  # if the display name is present
  #   CONCAT gives display_name + name which will sort by display name basically.
  scope :alphabetical_order,
    order(<<-EOSQL
      LOWER(
        COALESCE(
          CONCAT(groups.full_name, groups.name),
          groups.name
        )
      ) ASC
    EOSQL
   )

  scope :recent, :order => 'groups.created_at DESC', :conditions => ["groups.created_at > ?", RECENT_TIME.ago]
  scope :by_created_at, :order => 'groups.created_at DESC'

  scope :names_only, :select => 'full_name, name'

  # filters the groups based on their name and full name
  # filter is a sql query string
  scope :named_like, lambda { |filter|
    { :conditions => ["(groups.name LIKE ? OR groups.full_name LIKE ? )",
            filter, filter] }
  }

  scope :in_location, lambda { |options|
    country_id = options[:country_id]
    admin_code_id = options[:state_id]
    city_id = options[:city_id]
    conditions = ["gl.id = profiles.geo_location_id and gl.geo_country_id=?",country_id]
    if admin_code_id =~ /\d+/
      conditions[0] << " and gl.geo_admin_code_id=?"
      conditions << admin_code_id
    end
    if city_id =~ /\d+/
      conditions[0] << " and gl.geo_place_id=?"
      conditions << city_id
    end
    { :joins => "join geo_locations as gl",
      :conditions => conditions
    }
  }

  ##
  ## GROUP INFORMATION
  ##

  include Crabgrass::Validations
  validates_handle :name
  before_validation :clean_names

  def clean_names
    t_name = read_attribute(:name)
    if t_name
      write_attribute(:name, t_name.downcase)
    end

    t_name = read_attribute(:full_name)
    if t_name
      write_attribute(:full_name, t_name.gsub(/[&<>]/,''))
    end
  end

  # the code shouldn't call find_by_name directly, because the group name
  # might contain a space in it, which we store in the database as a plus.
  def self.find_by_name(name)
    return nil unless name.present?
    Group.find(:first, :conditions => ['groups.name = ?', name.gsub(' ','+')])
  end

  # keyring_code used by acts_as_locked and pathfinder
  def keyring_code
    "%04d" % "8#{id}"
  end

  # name stuff
  def to_param; name; end
  def display_name; full_name.presence || name; end
  def short_name; name; end
  def cut_name; name[0..20]; end
  def both_names
    return name if name == display_name
    return "%s (%s)" % [display_name, name]
  end

  # visual identity
  def banner_style
    @style ||= Style.new(:color => "#eef", :background_color => "#1B5790")
  end

  #
  # type of group
  #
  def committee?
    read_attribute(:type) == 'Committee' || instance_of?(Committee)
  end
  def network?
    read_attribute(:type) == 'Network' || instance_of?(Network)
  end
  def council?
    read_attribute(:type) == 'Council' || instance_of?(Council)
  end
  def normal?
    read_attribute(:type).empty? || instance_of?(Group)
  end

  def group_type; self.class.model_name.human; end

  # age of group
  def recent?
    self.created_at > RECENT_TIME.ago
  end

  ##
  ## PROFILE
  ##

  has_many :profiles, :as => 'entity', :dependent => :destroy, :extend => ProfileMethods
  has_many :wikis, :through => :profiles
  has_one :public_wiki,
    :through => :profiles,
    :source => :wiki,
    :conditions => {'profiles.stranger' => true}
  has_one :private_wiki,
    :through => :profiles,
    :source => :wiki,
    :conditions => {'profiles.friend' => true}

  def profile
    self.profiles.visible_by(User.current)
  end

  ##
  ## MENU_ITEMS
  ##

  has_many :menu_items, :dependent => :destroy, :order => :position do

    def update_order(menu_item_ids)
      menu_item_ids.each_with_index do |id, position|
        # find the menu_item with this id
        menu_item = self.find(id)
        menu_item.update_attribute(:position, position)
      end
      self
    end
  end

  # creates a menu item for the group and returns it.
  def add_menu_item(params)
    item = MenuItem.create!(params.merge(:group_id => self.id, :position => self.menu_items.count))
  end


  # TODO: add visibility to menu_items so they can be visible to members only.
  # def menu_items
  #   self.menu_items.visible_by(User.current)
  # end

  ##
  ## AVATAR
  ##

  public

  belongs_to :avatar, :dependent => :destroy

  protected

  before_save :save_avatar_if_needed
  def save_avatar_if_needed
    avatar.save if avatar and avatar.changed?
  end

  ##
  ## DESTROY
  ##

  public

  def destroy_by(user)
    # needed for the activity
    self.destroyed_by = user
    self.children.each {|committee| committee.destroyed_by = user}
    self.destroy
  end

  protected

  # make destroy protected
  # callers should use destroy_by
  def destroy
    super
  end

  ##
  ## RELATIONSHIP TO ASSOCIATED DATA
  ##

  protected

  after_destroy :destroy_requests
  def destroy_requests
    Request.destroy_for_group(self)
  end

  after_destroy :update_networks
  def update_networks
    self.networks.each do |network|
      Group.increment_counter(:version, network.id)
    end
  end

  ##
  ## PERMISSIONS
  ##

  #
  # These callbacks are responsible for setting up and tearing down
  # the permissions for groups. The actual methods are defined in
  # config/permissions.rb. Committees override these callbacks.
  #
  after_create :call_create_permissions
  def call_create_permissions
    create_permissions
  end
  after_destroy :call_destroy_permissions
  def call_destroy_permissions
    destroy_permissions
  end

  ##
  ## GROUP SETTINGS
  ##

  public

  has_one :group_setting
  # can't remember the way to do this automatically
  after_create :create_group_setting
  def create_group_setting
    self.group_setting = GroupSetting.new
    self.group_setting.save
  end

  #Defaults!
  def tool_allowed(tool)
    group_setting.allowed_tools.nil? or group_setting.allowed_tools.index(tool)
  end

  #Defaults!
  def layout(section)
    template_data = (group_setting || GroupSetting.new).template_data || {"section1" => "group_wiki", "section2" => "recent_pages"}
    template_data[section]
  end


  # migrate permissions from pre-CastleGates databases to CastleGates.
  # Called from cg:upgrade:migrate_group_permissions task.
  def migrate_permissions!
    print '.' if id % 10 == 0
    # get holders
    public_holder = CastleGates::Holder[:public]
    public_gates = profiles.public.to_gates
    set_access! public_holder => public_gates
  end

  protected

  after_save :update_name_copies

  # if our name has changed, ensure that denormalized references
  # to it also get changed
  def update_name_copies
    if name_changed? and !name_was.nil?
      Page.update_owner_name(self)
      Wiki.clear_all_html(self)   # in case there were links using the old name
      # update all committees (this will also trigger the after_save of committees)
      committees.each {|c|
        c.parent_name_changed
        c.save if c.name_changed?
      }
      User.increment_version(self.user_ids)
    end
  end

end
