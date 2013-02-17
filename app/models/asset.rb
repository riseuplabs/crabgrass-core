=begin

Assets use a lot of classes to manage a particular uploaded file:

  Asset          -- main asset class.
  ImageAsset     -- a subclass of Asset using STI, for example.
  Asset::Version -- all the past and present versions of the main asset.
  Thumbnail      -- a processed representation of an Asset (usually a small image)

  Every asset has many versions. Each asset, and each version, also
  have many thumbnails.

  Additionally, three modules are included by Asset:
    AssetExtension::Upload      -- handles uploading data
    AssetExtension::Storage     -- handles where/how data is stored
    AssetExtension::Thumbnails  -- handles the creation of the thumbnails

  Asset::Versions have the latter two included as well.

  Additional modules used by assets:
    Media::MimeType -- where all the mime magicky stuff happens, including
                       determining which Asset subclass to create.
    Media::Process  -- processors for creating thumbnails.

TODO:

  * Image assets that are smaller than the thumbnails should not get thumbnails,
    or should only get one thumbnail if the format differs. It is a waste of space
    to keep four copies of the same image! (albeit, a very tiny image)

  create_table "asset_versions", :force => true do |t|
    t.integer  "asset_id",       :limit => 11
    t.integer  "version",        :limit => 11
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size",           :limit => 11
    t.integer  "width",          :limit => 11
    t.integer  "height",         :limit => 11
    t.integer  "page_id",        :limit => 11
    t.integer  "user_id",        :limit => 11
    t.text     "comment"
    t.datetime "created_at"
    t.string   "versioned_type"
    t.datetime "updated_at"
  end

  add_index "asset_versions", ["asset_id"], :name => "index_asset_versions_asset_id"
  add_index "asset_versions", ["version"], :name => "index_asset_versions_version"
  add_index "asset_versions", ["page_id"], :name => "index_asset_versions_page_id"

  create_table "assets", :force => true do |t|
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size",          :limit => 11
    t.integer  "width",         :limit => 11
    t.integer  "height",        :limit => 11
    t.integer  "page_id",       :limit => 11
    t.datetime "created_at"
    t.integer  "version",       :limit => 11
    t.string   "type"
    t.integer  "page_terms_id", :limit => 11
    t.boolean  "is_attachment",               :default => false
    t.boolean  "is_image"
    t.boolean  "is_audio"
    t.boolean  "is_video"
    t.boolean  "is_document"
    t.datetime "updated_at"
    t.string   "caption"
    t.datetime "taken_at"
    t.string   "credit"
    t.integer  "user_id",        :limit => 11
    t.text     "comment"
  end

  add_index "assets", ["version"], :name => "index_assets_version"
  add_index "assets", ["page_id"], :name => "index_assets_page_id"
  add_index "assets", ["page_terms_id"], :name => "pterms"

=end

class Asset < ActiveRecord::Base
  include Crabgrass::Page::Data

  # Polymorph does not seem to be working with subclasses of Asset. For parent_type,
  # it always picks "Asset". So, we hardcode what the query should be:
  POLYMORPH_AS_PARENT = lambda { |a| "SELECT * FROM thumbnails WHERE parent_id = #{self.id} AND parent_type = \"#{self.type_as_parent}\"" }

  # fields in assets table not in asset_versions
  NON_VERSIONED = %w(page_terms_id is_attachment is_image is_audio is_video is_document caption taken_at credit)

  # This is included here because Asset may take new attachment file data, but
  # Asset::Version and Thumbnail don't need to.
  include AssetExtension::Upload
  validates_presence_of :filename, :unless => 'new_record?'


  ##
  ## ACCESS
  ##

  # checks wether the given `user' has permission `perm' on this Asset.
  #
  # there is only one way that a user may have access to an asset:
  #
  #    if the user also has access to the asset's page
  #
  # not all assets have a page. for them, this test will fail.
  # (for example, assets that are part of profiles).
  #
  # Adding an asset to a gallery does not confir any special access.
  # If you have access to the gallery, but not an asset in the gallery, then
  # you are not able to see the asset.
  #
  # Return value:
  #   returns always true
  #   raises PermissionDenied if the user has no access.
  #
  # has_access! is called by User.may?
  #
  def has_access!(perm, user)
    # If the perm is :view, use the quick visibility check
    if perm == :view
      return true if self.visible?(user)
    end
    raise PermissionDenied unless self.page
    self.page.has_access!(perm, user)
  end

  def participation_for_groups ids
    gparts = self.page.participation_for_groups(ids)
    if(self.galleries.any?)
      gparts += self.galleries.map(&:participation_for_groups)
    end
    return gparts.flatten
  end


  ##
  ## FINDERS
  ##

  # Returns true if this Asset is currently the cover of the given `gallery'.
  # A Gallery can only have one cover at a time.
  def is_cover_of? gallery
    raise ArgumentError.new() unless gallery.kind_of? Gallery
    showing = gallery.showings.find_by_asset_id(self.id)
    !showing.nil? && showing.is_cover
  end

  scope :not_attachment, :conditions => ['is_attachment = ?',false]

  # one of :image, :audio, :video, :document
  scope :media_type, lambda {|type|
    raise TypeError.new unless [:image,:audio,:video,:document].include?(type)
    {:conditions => ["is_#{type} = ?",true]}
  }

  ##
  ## METHODS COMMON TO ASSET AND ASSET::VERSION
  ##

  acts_as_versioned do
    def self.included(base)
      base.send :include, AssetExtension::Storage
      base.send :include, AssetExtension::Thumbnails
      base.belongs_to :user
      base.has_many :thumbnails, :class_name => '::Thumbnail',
        :dependent => :destroy, :finder_sql => POLYMORPH_AS_PARENT do
        def preview_images
          small, medium, large = nil
          self.each do |tn|
            if tn.name == 'small'
              small = tn
            elsif tn.name == 'medium'
              medium = tn
            elsif tn.name == 'large'
              large = tn
            end
          end
          large = nil if medium && large && large.size == medium.size
          medium = nil if small && medium && medium.size == small.size
          [small, medium, large].compact
        end
      end
      base.define_thumbnails( {} ) # root Asset class has no thumbnails
    end

    # file extension, with '.'
    def ext; File.extname(filename); end

    # file name without extension
    def basename; File.basename(filename, ext); end

    def big_icon
      "mime_#{Media::MimeType.icon_for(content_type)}"
    end

    def small_icon
      "mime_#{Media::MimeType.icon_for(content_type)}"
    end

    def format_description
      Media::MimeType.description_from_mime_type(content_type)
    end

    def content_type
      read_attribute('content_type') || 'application/octet-stream'
    end
  end
  self.non_versioned_columns.concat NON_VERSIONED

  ##
  ## DEFINE THE CLASS Asset::Version
  ##

  # to be overridden in Asset::Version
  def version_path; []; end
  def is_version?; false; end
  def type_as_parent; self.type; end

  versioned_class.class_eval do
    delegate :page, :public?, :has_access!, :to => :asset

    # all our paths will have version info inserted into them
    def version_path
      ['versions',version.to_s]
    end

    # our path id will be the id of the main asset
    def path_id
      asset.path_id if asset
    end

    # this object is a version, not the main asset
    def is_version?; true; end

    # delegate call to thumbdefs to our original Asset subclass.
    # eg: Asset::Version#thumbdefs --> ImageAsset.thumbdefs
    def thumbdefs
      versioned_type.constantize.class_thumbdefs if versioned_type
    end

    def type_as_parent
      'Asset::Version'
    end

    # for this version, hard link the files from the main asset
    after_create :clone_files_from_asset, :clone_thumbnails_from_asset
    def clone_files_from_asset
      clone_files_from(asset); true
    end
    def clone_thumbnails_from_asset
      clone_thumbnails_from(asset); true
    end

    # fixes warning: toplevel constant Asset referenced by Asset::Asset
    Asset = ::Asset
  end

  ##
  ## RELATIONSHIP TO PAGES
  ##

  # an asset might have two different types of associations to a page. it could
  # be the data of page (1), or it could be an attachment of the page (2).
  belongs_to :parent_page, :foreign_key => 'page_id', :class_name => 'Page' # (2)
  def page()
    page = page_id ? parent_page : pages.first
    return page
  end

  def create_page(user, group)
    # run validations so filname gets set
    self.valid?
    page_params = {
      :title => self.basename,
      :summary =>"Asset Page for #{self.basename}. This asset was used without a page - for example in a group wiki. This page was created automatically for the asset.",
      :tag_list => "",
      :user => user,
      :access => "admin",
      :data => self
    }
    if group
      page_params.merge! :share_with => {group.name => {:access =>  "1"}}
    end
    self.parent_page = AssetPage.create!(page_params)
  end

  # some asset subclasses (like AudioAsset) will display using flash
  # they should override this method to say which partial will render this code
  def embedding_partial
    nil
  end

  before_save :update_is_attachment
  def update_is_attachment
    if page_id_changed?
      self.is_attachment = true if page_id
      self.page_terms = (page.page_terms if page)
    end
  end

  ##
  ## ACCESS
  ##

  def update_access
    public? ? add_symlink : remove_symlink
  end

  def public?
    page.nil? or page.public?
  end

  ##
  ## ASSET CREATION
  ##

  #
  # creates an Asset of the appropriate subclass (ie ImageAsset).
  #
  def self.create_from_params(attributes = nil, &block)
    begin
      return self.create_from_params!(attributes, &block)
    rescue Exception => exc
      puts 'Error creating asset: ' + exc.to_s
      puts exc.clean_backtrace
      return nil
    end
  end

  def self.create_from_params!(attributes = nil, &block)
    asset_class(attributes).create!(attributes, &block)
  end

  #
  # Like create_from_params(), but builds the asset in memory and does not save it.
  # In order for fields like 'filename' to get set, the validations must run. So
  # if you want to access filename after Asset.build(), try valid?() or validate!()
  #
  def self.build(attributes = nil, &block)
    asset = asset_class(attributes).new(attributes, &block)
    asset.update_media_flags
    asset
  end

  before_create :set_default_type
  def set_default_type
    self.type ||= 'Asset'  # make Asset the default type so Asset::Version.versioned_type will be accurate.
  end

  private

  #
  # returns the appropriate asset class, ie ImageAsset, for the attributes passed in.
  #
  def self.asset_class(attributes)
    if attributes
      content_type = if attributes[:uploaded_data]
        mime_type_from_data(attributes[:uploaded_data])
      elsif attributes[:data]
        attributes[:content_type]
      end
      return class_for_mime_type( content_type )
    else
      self
    end
  end

  #
  # MIME TYPES
  #

  # eg: 'image/jpg' --> ImageAsset
  def self.class_for_mime_type(mime)
    if mime
      Media::MimeType.asset_class_from_mime_type(mime).constantize
    else
      Asset
    end
  end

  #
  # returns a mime type of the file_data
  #
  def self.mime_type_from_data(file_data)
    if file_data and file_data.any?
      file_data.content_type || Media::MimeType.mime_type_from_extension(file_data.original_filename)
    end
  end

  public

  ##
  ## MEDIA TYPES
  ##

  before_save :reset_media_flags
  def reset_media_flags
    if content_type_changed?
      is_audio = false
      is_video = false
      is_image = false
      is_document = false
      update_media_flags()
    end
  end

  # to be overridden by subclasses
  def update_media_flags() end

  # returns either :landscape or :portrait, depending on the format of the
  # image.
  def image_format
    raise TypeError unless self.respond_to?(:width) && self.respond_to?(:height)
    return :landscape if width.nil? or height.nil?
    self.width > self.height ? :landscape : :portrait
  end

  acts_as_extensible

end
