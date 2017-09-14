# create_table "groups", :force => true do |t|
#   t.string   "name"
#   t.string   "full_name"
#   t.string   "summary"
#   t.string   "url"
#   t.string   "type"
#   t.integer  "parent_id",  :limit => 11
#   t.integer  "council_id", :limit => 11
#   t.datetime "created_at"
#   t.datetime "updated_at"
#   t.integer  "avatar_id",  :limit => 11
#   t.string   "style"
#   t.string   "language",   :limit => 5
#   t.integer  "version",    :limit => 11, :default => 0
#   t.integer  "min_stars",  :limit => 11, :default => 1
#   t.integer  "site_id",    :limit => 11
# end
#
#   associations:
#   group.children   => groups
#   group.parent     => group
#   group.council    => nil or group
#   group.users      => users

class Group < ActiveRecord::Base
  extend RouteInheritance # subclasses use /groups routes

  # core group extentions
  include Group::Groups     # group <--> group behavior
  include Group::Users      # group <--> user behavior
  include Group::Featured   # this makes this group's pages featureable
  include Group::Pages      # group <--> page behavior
  include Group::Cache      # only versioning so far

  acts_as_castle

  # not saved to database, just used by activity feed:
  attr_accessor :created_by

  # group <--> chat channel relationship
  has_one :chat_channel

  ##
  ## FINDERS
  ##

  # find groups that do not contain the given user
  # used in autocomplete where the users groups are all preloaded
  def self.without_member(user)
    group_ids = user.all_group_ids
    group_ids.any? ?
      where('NOT groups.id IN (?)', group_ids) :
      self
  end

  # finds groups that are of type Group (but not Committee or Network)
  def self.only_groups
    where(type: nil)
  end

  def self.only_type(*args)
    group_type = args.first.to_s.capitalize
    if group_type == 'Group'
      only_groups
    else
      where(type: group_type)
    end
  end

  def self.groups_and_networks
    where("groups.type IS NULL OR groups.type = 'Network'")
  end

  def self.all_networks_for(user)
    only_type('Network')
      .where(id: user.all_group_id_cache)
  end

  # alphabetized and (optional) limited to +letter+
  def self.alphabetized(letter)
    if letter == '#'
      where('name REGEXP ?', '^[^a-z]').alphabetical_order
    elsif letter.present?
      where('name LIKE ?', "#{letter}%").alphabetical_order
    else
      alphabetical_order
    end
  end

  # this is a little mysql magic to get what we want:
  # We want to sort by display_name.presence || name
  # if the display_name is NULL
  #   CONCAT is null and we get name from COALESCE
  # if the display_name is ""
  #   CONCAT gives us the name
  # if the display name is present
  #   CONCAT gives display_name + name which will sort by display name basically.
  def self.alphabetical_order
    order <<-EOSQL
      LOWER(
        COALESCE(
          CONCAT(groups.full_name, groups.name),
          groups.name
        )
      ) ASC
    EOSQL
  end

  def self.recent
    by_created_at.where('groups.created_at > ?', RECENT_TIME.ago)
  end

  def self.by_created_at
    order('groups.created_at DESC')
  end

  def self.names_only
    select('full_name, name')
  end

  # filters the groups based on their name and full name
  # filter is a sql query string
  def self.named_like(filter)
    where '(groups.name LIKE ? OR groups.full_name LIKE ? )',
          filter, filter
  end

  ##
  ## GROUP INFORMATION
  ##

  def public?
    access? public: :view
  end

  include Crabgrass::Validations
  validates_handle :name
  before_validation :clean_names

  def clean_names
    t_name = read_attribute(:name)
    write_attribute(:name, t_name.downcase) if t_name

    t_name = read_attribute(:full_name)
    write_attribute(:full_name, t_name.gsub(/[&<>]/, '')) if t_name
  end

  # the code shouldn't call find_by_name directly, because the group name
  # might contain a space in it, which we store in the database as a plus.
  def self.find_by_name(name)
    return nil unless name.present?
    Group.where(name: name.tr(' ', '+')).first
  end

  # keyring_code used by acts_as_locked and pathfinder
  def keyring_code
    format('%04d', "8#{id}")
  end

  # name stuff
  def to_param
    name
  end

  def display_name
    full_name.presence || name
  end

  def short_name
    name
  end

  def cut_name
    name[0..20]
  end

  def both_names
    return name if name == display_name
    format('%s (%s)', display_name, name)
  end

  # visual identity
  def banner_style
    @style ||= Style.new(color: '#eef', background_color: '#1B5790')
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

  def group_type
    self.class.model_name.human
  end

  # age of group
  def recent?
    created_at > RECENT_TIME.ago
  end

  ##
  ## PROFILE
  ##

  has_many :profiles, as: 'entity', dependent: :destroy, extend: ProfileMethods

  has_one :public_profile,
          -> { where stranger: true },
          as: 'entity',
          class_name: 'Profile'

  has_one :private_profile,
          -> { where friend: true },
          as: 'entity',
          class_name: 'Profile'

  has_many :wikis, through: :profiles

  def public_wiki
    public_profile.try.wiki
  end

  def public_wiki=(wiki)
    profiles.public.wiki = wiki
  end

  def private_wiki
    private_profile.try.wiki
  end

  def private_wiki=(wiki)
    profiles.private.wiki = wiki
  end

  ##
  ## AVATAR
  ##

  public

  belongs_to :avatar, dependent: :destroy

  protected

  before_save :save_avatar_if_needed
  def save_avatar_if_needed
    avatar.save if avatar and avatar.changed?
  end

  ##
  ## RELATIONSHIP TO ASSOCIATED DATA
  ##

  protected

  # TODO: why don't we use an association with dependend: :destroy?
  after_destroy :destroy_requests
  def destroy_requests
    Request.destroy_for_group(self)
  end

  after_destroy :update_networks
  def update_networks
    networks.each do |network|
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

  public

  # migrate permissions from pre-CastleGates databases to CastleGates.
  # Called from cg:upgrade:migrate_group_permissions task.
  # Overwritten by Committee to take into account parent permissions
  def migrate_permissions!
    if public_profile
      set_access! public: public_profile.to_group_gates
    else
      set_access! public: []
    end
  end

  protected

  after_save :update_name_copies

  # if our name has changed, ensure that denormalized references
  # to it also get changed
  def update_name_copies
    if name_changed? and !name_was.nil?
      pages_owned.update_all(owner_name: name)
      Wiki.clear_all_html(self) # in case there were links using the old name
      # update all committees (this will also trigger the after_save of committees)
      committees.each do |c|
        c.parent_name_changed
        c.save if c.name_changed?
      end
      User.increment_version(user_ids)
    end
  end
end
