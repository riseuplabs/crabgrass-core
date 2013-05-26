#  This is a generic versioned wiki, primarily used by the WikiPage,
#  but also used directly sometimes by other classes (like for Group's
#  landing page wiki's).
#
#
#     create_table "wikis", :force => true do |t|
#       t.text     "body"
#       t.text     "body_html"
#       t.datetime "updated_at"
#       t.integer  "user_id",       :limit => 11
#       t.integer  "version",       :limit => 11
#       t.text     "raw_structure"
#     end
#
#     add_index "wikis", ["user_id"], :name => "index_wikis_user_id"
#

##

# requirements/ideas:
# 1. nothing should get saved until we say save!
# 2. updating body automatically updates html and structure
# 3. wiki should never get saved with body/body products mismatch
# 4. loaded wiki should see only the latest body products, if body was updated from outside
class Wiki < ActiveRecord::Base
  include WikiExtension::Locking
  include WikiExtension::Sections
  include WikiExtension::Versioning

  # a wiki can be used in multiple places: pages or profiles
  has_many :pages, :as => :data
  has_one :profile
  has_one :group, :through => :profile, :source => :entity, :source_type => 'Group'
  attr_accessor :private # marks private group wikis during creation

  has_one :section_locks, :class_name => "WikiLock", :dependent => :destroy

  serialize :raw_structure, Hash

  acts_as_versioned :if => :create_new_version? do
    def self.included(base)
      base.belongs_to :user
      base.serialize :raw_structure, Hash
    end
  end
  # versions are so tightly coupled that wiki.versions should always be up to date
  # this must be declared after acts_as_versioned, since AAV declares its own after_save
  # callback that create versions
  # locks should reloaded too, since some locks may become invalid (because of section heading changes)
  after_save :reload_versions_and_locks

  # only save a new version if the body has changed
  # need more control than composed of
  attr_reader :structure

  before_save :update_body_html_and_structure
  before_save :update_latest_version_record

  # see description below.
  after_save :save_page_after_save

  # constant for length to show preview rather than full wiki
  PREVIEW_CHARS = 500

  # section locks should never be nil
  alias_method :existing_section_locks, :section_locks
  def section_locks(force_reload = false)
    # current section_locks or create a new one if it doesn't exist
    locks = (existing_section_locks(force_reload) || build_section_locks(:wiki => self))
    # section_locks should always have self as its wiki instance
    # in case self.body is updated (and section names get changed)
    locks.wiki = self
    locks
  end

  def label
    return :create_a_new_thing.t(:thing => 'Wiki') if self.new_record?
    if self.profile
      self.profile.public? ? :public_group_wiki : :private_group_wiki
    else
      :page_wiki
    end
  end

  # after the wiki text has been updated the page terms need to be rebuilt, so the
  # search index gets updated. For some reason this doesn't happen automatically
  # when saving the wiki, so we trigger a page save here.
  def save_page_after_save
    if page && page.type == 'WikiPage' && page.valid?
      page.save!
    end
  end

  #
  # similar to update_attributes!, but only for text
  # this method will perform unlocking and will check version numbers
  # it will skip version_checking if current_version is nil (useful for section editing)
  #
  def update_section!(section, user, current_version, text)
    check_and_unlock_section!(section, user, current_version)
    self.user = user
    save_section!(section, text)
  end

  # updating body will invalidate body_html
  # reading body_html or saving this wiki
  # will regenerate body_html from body if render_body_html_proc is available
  def body=(body)
    write_attribute(:body, body)
    # invalidate body_html and raw_structure
    if body_changed?
      write_attribute(:body_html, nil)
      write_attribute(:raw_structure, nil)
      @structure = nil
    end
  end

  def clear_html
    write_attribute(:body_html, nil)
  end

  # will render if not up to date
  def body_html
    update_body_html_and_structure

    read_attribute(:body_html).html_safe
  end

  def preview_html
    render_preview(PREVIEW_CHARS).try.html_safe
  end

  # will calculate structure if not up to date
  # calculating structure will also update body_html
  def raw_structure
    update_body_html_and_structure

    read_attribute(:raw_structure) || write_attribute(:raw_structure, {})
  end

  def structure
    @structure ||= WikiExtension::WikiStructure.new(raw_structure, body.to_s)
  end

  # sets the block used for rendering the body to html
  def render_body_html_proc &block
    @render_body_html_proc = block
  end

  # renders body_html and calculates structure if needed
  def update_body_html_and_structure
    return unless needs_rendering?
    write_attribute(:body_html, render_body_html)
    write_attribute(:raw_structure, render_raw_structure)
  end

  # returns true if wiki body is fresher than body_html
  def needs_rendering?
    html = read_attribute(:body_html)
    rs = read_attribute(:raw_structure)

    # whenever we set body, we reset body_html to nil, so this condition will
    # be true whenever body is changed
    # it will also be true when body_html is invalidated externally (like with Wiki.clear_all_html)
    (html.blank? != body.blank?) or rs.blank?
  end

  # reload the association
  def reload_versions_and_locks
    self.versions(true)
    # will clear out obsolete locks (expired or non-existant sections)
    self.section_locks(true)
  end

  ##
  ## CONTEXT
  ##

  # A wiki can be used in different contexts. For now the context is either
  # a group or the wikis pages context.

  def context
    self.group || self.page.try.owner
  end

  ##
  ## RELATIONSHIP TO GROUPS
  ##

  # Clears the rendered HTML. This should be called when a group/user name is
  # changed or some other event happens which might affect how the HTML is
  # rendered by greencloth.
  def self.clear_all_html(owner)
    # for wiki's owned by pages
    Wiki.connection.execute(quote_sql([
      "UPDATE wikis, pages SET wikis.body_html = NULL WHERE pages.data_id = wikis.id AND pages.data_type = 'Wiki' AND pages.owner_id = ? AND pages.owner_type = ? ",
      owner.id,
      owner.class.base_class.name
    ]))

    # for wiki's owned by by profiles
    Wiki.connection.execute(quote_sql([
      "UPDATE wikis, profiles SET wikis.body_html = NULL WHERE profiles.wiki_id = wikis.id AND profiles.entity_id = ? AND profiles.entity_type = ?",
      owner.id,
      owner.class.base_class.name
    ]))
  end

  ##
  ## RELATIONSHIP TO PAGES
  ##

  # returns the page associated with this wiki, if any.
  def page
    # we do this so that we can access the page even before page or wiki are saved
    return pages.first if pages.any?
    return @page
  end

  def page=(p) #:nodoc:
    @page = p
  end

  ##
  ## PROTECTED METHODS
  ##

  protected

  #
  # Check to make sure that user may unlock the section and
  # that the version has not changed. If the user still has a valid lock
  # we allow saving even if the version has changed.
  #
  def check_and_unlock_section!(section, user, current_version)
    if sections_locked_for(user).include? section
      raise SectionLockedOnSaveError.new(section, locker_of(section))
    end
    if current_version and self.version > current_version.to_i
      # our version might be outdated but if the last edit
      # was in a different section we still have the lock
      # and we can still save.
      unless user == locker_of(section)
        raise VersionExistsError.new(self.versions.last)
      end
    end
    release_my_lock!(section, user)
  end

  def render_preview(length)
    return unless content = truncated_body(length)
    if @render_body_html_proc
      @render_body_html_proc.call(content)
    else
      GreenCloth.new(content, link_context, [:outline]).to_html
    end
  end

  # # used when wiki is rendered for deciding the prefix for some link urls
  def link_context
    if page and page.owner_name
      #.sub(/\+.*$/,'') # remove everything after +
      page.owner_name
    elsif profile
      profile.entity.name
    else
      'page'
    end
  end

  # returns html for wiki body
  # user render_body_html_proc if available
  # or default GreenCloth rendering otherwise
  def render_body_html
    if @render_body_html_proc
      @render_body_html_proc.call(body.to_s)
    else
      GreenCloth.new(body.to_s, link_context, [:outline]).to_html
    end
  end

  def render_raw_structure
    GreenCloth.new(body.to_s).to_structure
  end

  def truncated_body(length)
    return nil if body.nil?
    return body if body.length < length
    cut = body.to_s[0...length-3] + '...'
    cut.gsub! /^\[\[toc\]\]$/, ''
    cut
  end

  class Version < ActiveRecord::Base


    before_destroy :confirm_existance_of_other_version

    scope :most_recent, :order => 'version DESC'

    self.per_page = 10

    def confirm_existance_of_other_version
      self.previous || self.next || false
    end

    def to_s
      to_param
    end

    def to_param
      self.version.to_s
    end

    def diff_id
      "#{previous.to_param}-#{self.to_param}"
    end

    def body_html
      read_attribute(:body_html).try :html_safe
    end

  end

end

