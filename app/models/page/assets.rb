#
# Page relationship to Asset
#
# It is a little confusing, but there are many possible page <> asset
# relationships:
#
# attachments:
#
#   asset belongs to parent_page (this file)
#   page has many assets (this file)
#
# page data (polymorphic):
#
#   page belongs to data (which is really an asset) (page.rb)
#   asset has many pages (as data) (page_data.rb)
#
# gallery:
#
#   page has many assets through showings (gallery tool)
#   asset has many pages through showings (gallery tool)
#
#
module Page::Assets
  def self.included(base)
    base.instance_eval do
      has_many   :assets, dependent: :destroy
      belongs_to :cover, class_name: 'Asset'

      before_save :update_media_flags, if: :data_id_changed?
      after_save :update_attachment_access, if: :public_changed?
    end
  end

  public

  # if a page has a cover that's not an Asset record
  # page subclasses should override this method should return its location
  def external_cover_url
    nil
  end

  # Adds an asset as an attachment to this page. The asset may be in the form of
  # a Hash or an Asset, either already created or new_record?()
  #
  # Additionally, this method will work with pages that saved or are new_record?()
  #
  # Available options:
  # - :cover -- if true, make this asset a cover asset
  # - :filename -- if set, rename the asset using this filename
  #
  def add_attachment!(asset, options = {})
    asset = Asset.build(asset) if asset.is_a? Hash
    asset.parent_page = self

    assets << asset
    self.cover = asset if options[:cover]
    asset.base_filename = options[:filename] if options[:filename].present?

    asset.save! if asset.persisted?

    if persisted?
      assets.reset
      save! if cover_id_changed?
    end

    asset
  end

  protected

  ##
  ## CALLBACKS
  ##

  # sets the default media flags for this page. can be overridden by the subclasses.
  def update_media_flags
    if data
      self.is_image = data.is_image? if data.respond_to?('is_image?')
      self.is_audio = data.is_audio? if data.respond_to?('is_audio?')
      self.is_video = data.is_video? if data.respond_to?('is_video?')
      self.is_document = data.is_document? if data.respond_to?('is_document?')
    end
    true
  end

  # update attachment permissions
  def update_attachment_access
    assets.each(&:update_access)
    true
  end
end
