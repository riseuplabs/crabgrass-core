=begin

PAGE.RB

A Page is the main content class. All actual content is a subclass of this class.

denormalization
---------------

  * updated_by_login
  * created_by_login
  * owner_name

Upon further investigation, I am not sure that these are needed.

schema
--------

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "resolved",                         :default => true
    t.boolean  "public"
    t.integer  "created_by_id",      :limit => 11
    t.integer  "updated_by_id",      :limit => 11
    t.text     "summary"
    t.string   "type"
    t.integer  "message_count",      :limit => 11, :default => 0
    t.integer  "data_id",            :limit => 11
    t.string   "data_type"
    t.integer  "contributors_count", :limit => 11, :default => 0
    t.string   "name"
    t.string   "updated_by_login"
    t.string   "created_by_login"
    t.integer  "flow",               :limit => 11
    t.integer  "stars",              :limit => 11, :default => 0
    t.integer  "views_count",        :limit => 11, :default => 0,    :null => false
    t.integer  "owner_id",           :limit => 11
    t.string   "owner_type"
    t.string   "owner_name"
    t.boolean  "is_image"
    t.boolean  "is_audio"
    t.boolean  "is_video"
    t.boolean  "is_document"
    t.integer  "site_id",            :limit => 11
    t.datetime "happens_at"
  end

  add_index "pages", ["name","owner_id"], :name => "index_pages_on_name"
  add_index "pages", ["created_by_id"], :name => "index_page_created_by_id"
  add_index "pages", ["updated_by_id"], :name => "index_page_updated_by_id"
  add_index "pages", ["type"], :name => "index_pages_on_type"
  add_index "pages", ["flow"], :name => "index_pages_on_flow"
  add_index "pages", ["public"], :name => "index_pages_on_public"
  add_index "pages", ["resolved"], :name => "index_pages_on_resolved"
  add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
  add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"
  execute "CREATE INDEX owner_name_4 ON pages (owner_name(4))"

  Yeah, so, there are way too many indices on the pages table.
=end

class Page < ActiveRecord::Base
  extend RouteInheritance          # subclasses use /pages routes

  include Page::Users           # page <> users relationship
  include Page::Groups          # page <> group relationship
  include Page::Assets          # page <> asset relationship
  include Page::Comments        # page <> post relationship
  include Page::Create          # page creation
  include Page::Subclass        # page subclassing
  include Page::Index           # page full text searching
  include Page::Starring        # star specific functionality
  include Page::Stats           # page tracking views, edits and stars
  include Page::HistoryTracking # page <> page_history


  has_many :page_notices,
    class_name: 'Notice::PageNotice',
    as: :noticable,
    dependent: :delete_all


  # disable timestamps, we set the updated_at field through certain Page::History subclasses
  self.record_timestamps = false
  before_save :save_timestamps

  acts_as_path_findable

  def self.deleted
    where(flow: FLOW[:deleted])
  end

  def self.not_deleted
    where("pages.flow != %s", FLOW[:deleted])
  end

  ##
  ## PAGE NAMING
  ##

  # flexible finder. Finds pages by id or param
  def self.find(id)
    if id.to_s =~ /^\d+$/
      super
    else
      find_by_param(id)
    end
  end

  # find pages by id attached to a string or by name
  def self.find_by_param(param)
    # param contains id
    if param =~ /[ +](\d+)$/
      find($~[1])
    else
      find_by_name(param)
    end
  end

  validate :unique_name_in_context
  def unique_name_in_context
    if (name_changed? or owner_id_changed? or groups_changed) and name_taken?
      context = self.owner || self.created_by
      errors.add 'name', "is already used for another page by #{context.display_name}"
    elsif name_changed? and name.present?
      errors.add 'name', 'name is invalid' if name != name.nameize
    end
  end

  # string identifying a page within its context
  def name_url
    name.presence || friendly_url
  end

  # unique string for a page - including the id
  def friendly_url
    # strange corner case here: during page creation we set the id to 0
    # in order to get a meaningful page_share_path.
    # The title is still blank at that point.
    return id if title.blank?
    s = title.nameize
    # limit name length, and remove any half-cut trailing word
    s = s[0..40].sub(/-([^-])*$/,'') if s.length > 42
    "#{s}+#{id}"
  end
  alias_method :to_param, :friendly_url
  # used for caching access
  alias_method :to_s, :friendly_url

  # using only knowledge of this page, returns
  # best guess uri string, sans protocol/host/port.
  # ie /rainbows/what-a-fine-page+5234
  def uri
    owner_name.present? ? [owner_name, name_url].path : ['page', friendly_url].path
  end

  # returns true if self's unique page name is already in use by the same owner.
  def name_taken?
    return false unless self.name.present?
    if self.owner
      pages = Page.where name: self.name, owner_id: self.owner
    else
      pages = Page.where name: self.name, created_by_id: self.created_by_id
    end
    pages.detect{|p| p != self and p.flow != FLOW[:deleted]}
  end

  ##
  ## Livecycle
  ##

  def flow= flow
    if flow.kind_of?(Integer) || flow.nil?
      write_attribute(:flow, flow)
    elsif flow.kind_of?(Symbol) && FLOW[flow]
      write_attribute(:flow, FLOW[flow])
    else
      raise TypeError.new("Flow needs to be an integer or one of [#{FLOW.keys.join(', ')}]")
    end
  end

  def delete
    self.flow=:deleted
    self.save
  end

  def undelete
    write_attribute(:flow, FLOW[:normal])
    self.save
  end

  def deleted?
    flow == FLOW[:deleted]
  end

  def deleted_changed?
    flow_changed? && [flow_was, flow].include?(FLOW[:deleted])
  end
  ##
  ## TAGGING
  ##

  acts_as_taggable_on :tags
  before_save :clear_tag_cache

  def clear_tag_cache
    if @tags_changed
      User.clear_tag_cache(self.user_ids)
    end
  end

  #
  # Simulate ActiveRecord::Dirty behavior for the tags
  # This should be called whenever the page tags have been modified.
  #
  def tags_will_change!
    @tags_changed = true
  end

  ##
  ## RELATIONSHIP TO PAGE DATA
  ##

  belongs_to :data, polymorphic: true, dependent: :destroy

  validates_presence_of :title
  validates_associated :data

  def unresolve
    resolve(false)
  end
  def resolve(value=true)
    user_participations.each do |up|
      up.resolved = value
      up.save
    end
    self.resolved=value
    save
  end

  def association_will_change(assn)
    (@associations_to_save ||= []) << assn
  end

  def association_changed?
    @associations_to_save.any?
  end

  after_save :save_associations
  def save_associations
    return true unless @associations_to_save
    @associations_to_save.uniq.each do |assn|
      if assn == :posts
        discussion.posts.each {|post| post.save! if post.changed?}
      elsif assn == :users
        user_participations.each {|up| up.save! if up.changed?}
      elsif assn == :groups
        group_participations.each {|gp| gp.save! if gp.changed?}
      end
    end
    true
  end

  ##
  ## PAGE ACCESS CONTROL
  ##

  public

  # This method should never be called directly. It should only be called
  # from User#may?()
  #
  # possible access levels on participation objects:
  #   :none  -- always returns false
  #   :view  -- user can see the page.
  #   :edit  -- user can participate.
  #   :admin -- user can destroy the page, change access.
  #
  # :view should only return true if the user has access to view the page
  # because of participation objects, NOT because the page is public.
  #
  # DEPRECATED BEHAVIOR:
  # :edit should return false for deleted pages.
  #
  def has_access!(perm, user)

    ########################################################
    ## THESE ARE TEMPORARY HACKS...
    return false if tmp_hack_for_deleted_pages?(perm)
    ## END TEMP HACKS
    #########################################################

    participation = most_privileged_participation_for(user)
    allowed = participation.present? && participation.grants_access?(perm)
    allowed || raise(PermissionDenied.new)
  end

  # returns the participation object for entity with the highest access level.
  # If no participation exists, we return nil.
  def most_privileged_participation_for(entity)
    parts = []
    if entity.is_a? User
      parts << participation_for_user(entity)
      parts.concat participation_for_groups(entity.all_group_ids)
    elsif entity.is_a? Group
      parts << participation_for_group(entity)
    end
    parts.compact.min {|a,b| (a.access||100) <=> (b.access||100) }
  end

  # this should be in the database, for now hardwired as "true".
  # if true, then anyone who can view a page can comment on it.
  def public_comments?
    true
  end

  protected

  # do not allow comments or editing of deleted pages:
  def tmp_hack_for_deleted_pages?(perm)
    self.deleted? and (perm == :edit)
  end

  ##
  ## RELATIONSHIP TO ENTITIES (GROUPS OR USERS)
  ##

  public

  # every page is owned by a person or group.
  belongs_to :owner, polymorphic: true

  # Add a group or user to this page (by creating a corresponing
  # user_participation or group_participation object). This is the only way
  # that groups or users should be added to pages!
  def add(entity, attributes={})
    if entity.is_a? Enumerable
      entity.collect do |e|
        e.add_page(self,attributes)
      end
    else
      entity.add_page(self,attributes)
    end
  end

  # Remove a group or user from this page (by destroying the corresponing
  # user_participation or group_participation object). This is the only way
  # that groups or users should be removed from pages!
  # FIXME: removing the connection should be part of the participation.
  # This way we can test participation.destroyed? in page history and views.
  def remove(entity)
    if entity.is_a? Enumerable
      entity.each do |e|
        e.remove_page(self)
      end
    else
      entity.remove_page(self)
    end
    entity
  end

  # The owner may be a user or a group, or their name.
  # this attr is protected from mass assignment.
  def owner=(entity)
    if entity.is_a? String
      if entity.empty?
        entity = nil
      else
        entity = User.find_by_login(entity) || Group.find_by_name(entity)
      end
    end
    if entity.nil?
      if Conf.ensure_page_owner?
        raise ErrorMessage.new(I18n.t(:page_owner_error))
      else
        self.owner_id = nil
        self.owner_name = nil
        self.owner_type = nil
      end
    elsif self.owner_name != entity.name
      self.owner_id = entity.id
      self.owner_name = entity.name
      if entity.is_a? Group
        self.owner_type = "Group"
      elsif entity.is_a? User
        self.owner_type = "User"
      else
        raise 'must be user or group'
      end
      part = most_privileged_participation_for(entity)
      self.add(entity, access: :admin) unless part and part.access == ACCESS[:admin]
      return self.owner
    end
  end

  # returns the appropriate user_participation or group_participation record.
  # it would be better to use OOP, but this allows page to cache the results.
  def participation_for(entity)
    entity.is_a?(User) ? participation_for_user(entity) : participation_for_group(entity)
  end


  ##
  ## MISC. HELPERS
  ##

  public

  # tmp in-memory storage used by views
  def flag
    @flags ||= {}
  end

  def class_display_name
    self.class.class_display_name
  end

  # override this in subclasses…
  def supports_attachments
    true
  end

  protected

  def save_timestamps
    self.created_at = self.updated_at = Time.now if self.new_record?
  end

end
