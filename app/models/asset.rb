#
# Assets use a lot of classes to manage a particular uploaded file:
#
#   Asset          -- main asset class.
#   Asset::Image   -- a subclass of Asset using STI, for example.
#   Asset::Version -- all the past and present versions of the main asset.
#   Thumbnail      -- a processed representation of an Asset (usually a small image)
#
#   Every asset has many versions. Each asset, and each version, also
#   have many thumbnails.
#
#   Additionally, three modules are included by Asset:
#     Asset::Upload      -- handles uploading data
#     Asset::Storage     -- handles where/how data is stored
#     Asset::Thumbnails  -- handles the creation of the thumbnails
#
#   Asset::Versions have the latter two included as well.
#
# TODO:
#
#   * Image assets that are smaller than the thumbnails should not get thumbnails,
#     or should only get one thumbnail if the format differs. It is a waste of space
#     to keep four copies of the same image! (albeit, a very tiny image)

class Asset < ApplicationRecord
  include Crabgrass::Page::Data

  # fields in assets table not in asset_versions
  NON_VERSIONED = %w[page_terms_id is_attachment is_image is_audio is_video is_document caption taken_at credit].freeze

  # This is included here because Asset may take new attachment file data, but
  # Asset::Version and Thumbnail don't need to.
  include Asset::Upload
  validates_presence_of :filename, unless: :new_record?

  ##
  ## ACCESS
  ##

  def self.policy_class
    ::AssetPolicy
  end

  # checks wether the given `user' has permission `perm' on this Asset.
  #
  # This does not include checking if the asset is public.
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
      return true if visible?(user)
    end
    raise PermissionDenied unless page
    page.has_access!(perm, user)
  end

  def participation_for_groups(ids)
    gparts = page.participation_for_groups(ids)
    gparts += galleries.map(&:participation_for_groups) if galleries.any?
    gparts.flatten
  end

  ##
  ## FINDERS
  ##

  # Returns true if this Asset is currently the cover of the given `gallery'.
  # A Gallery can only have one cover at a time.
  def is_cover_of?(gallery)
    raise ArgumentError.new unless gallery.is_a? Gallery
    showing = gallery.showings.find_by_asset_id(id)
    !showing.nil? && showing.is_cover
  end

  def self.not_attachment
    where('is_attachment = ?', false)
  end

  # one of :image, :audio, :video, :document
  def self.media_type(type)
    raise TypeError.new unless %i[image audio video document].include?(type)
    where("is_#{type} = ?", true)
  end

  def version_or_self(version_id)
    return self if version_id.blank?
    versions.find_by_version(version_id)
  end

  ##
  ## METHODS COMMON TO ASSET AND ASSET::VERSION
  ##

  acts_as_versioned do
    def self.included(base)
      base.send :include, Asset::Storage
      base.send :include, Asset::Thumbnails
      base.belongs_to :user
      base.has_many :thumbnails, class_name: '::Thumbnail', as: :parent,
                                 dependent: :destroy do
        def preview_images
          small, medium, large = nil
          each do |tn|
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

        def other_formats
          reject { |t| %w[small medium large].include?(t.name) }
        end
      end
      base.define_thumbnails({}) # root Asset class has no thumbnails
    end

    # file extension, with '.'
    def ext
      File.extname(filename)
    end

    # file name without extension
    def basename
      File.basename(filename, ext)
    end

    def url(name = filename)
      path.url(name)
    end

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
  non_versioned_columns.concat NON_VERSIONED

  # to be overridden in Asset::Version
  def path
    @path ||= Storage::Path.new id: id, filename: filename
  end

  def is_version?
    false
  end

  ##
  ## RELATIONSHIP TO PAGES
  ##

  # an asset might have two different types of associations to a page. it could
  # be the data of page (1), or it could be an attachment of the page (2).
  belongs_to :parent_page, foreign_key: 'page_id', class_name: 'Page' # (2)
  def page
    page = page_id ? parent_page : pages.first
    page
  end

  def create_page(user, group)
    # run validations so filname gets set
    valid?
    page_params = {
      title: basename,
      summary: "Asset Page for #{basename}. This asset was used without a page - for example in a group wiki. This page was created automatically for the asset.",
      tag_list: '',
      user: user,
      access: 'admin',
      data: self
    }
    page_params[:share_with] = { group.name => { access: '1' } } if group
    self.parent_page = AssetPage.create!(page_params)
  end

  # some asset subclasses (like Asset::Audio) will display using flash
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
  # creates an Asset of the appropriate subclass (ie Asset::Image).
  #
  def self.create_from_params(attributes = nil, &block)
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
    self.type ||= 'Asset' # make Asset the default type so Asset::Version.versioned_type will be accurate.
  end

  private

  #
  # returns the appropriate asset class, ie Asset::Image, for the attributes passed in.
  #
  def self.asset_class(attributes)
    if attributes
      content_type = if attributes[:uploaded_data]
                       mime_type_from_data(attributes[:uploaded_data])
                     elsif attributes[:data]
                       attributes[:content_type]
      end
      class_for_mime_type(content_type)
    else
      self
    end
  end

  #
  # MIME TYPES
  #

  # eg: 'image/jpg' --> Asset::Image
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
    if file_data.present?
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
      update_media_flags
    end
  end

  # to be overridden by subclasses
  def update_media_flags() end

  # returns either :landscape or :portrait, depending on the format of the
  # image.
  def image_format
    raise TypeError unless respond_to?(:width) && respond_to?(:height)
    return :landscape if width.nil? or height.nil?
    width > height ? :landscape : :portrait
  end
end

require 'asset/version'
