class Gallery < Page
  include Page::RssData

  # A gallery is a collection of images, being presented to the user by a cover
  # page, an overview or a slideshow.

  has_many :showings,
           -> { order 'position' },
           dependent: :destroy

  has_many :images,
           -> { order 'showings.position' },
           through: :showings,
           source: :asset

  def update_media_flags
    self.is_image = true
  end

  # Galleries currently do not support attachments.
  # hence #=> false
  def supports_attachments
    false
  end

  # the ultimate method to add an image to a gallery. `position' can be left
  # nil - it then gets determined by acts_as_list (i.e. put it into the last
  # position).
  #
  # The `asset' needs to respond `true' on Asset#is_image?, else an appropriate
  # ErrorMessage is raised.
  #
  # This method always returns true. On failure an error is raised.
  def add_attachment!(asset_params, options = {})
    check_type!(asset_params)
    asset = super
    Showing.create! gallery: self, asset: asset
    asset
  end
  alias add_image! add_attachment!

  def sort_images(sorted_ids)
    sorted_ids.each_with_index do |id, index|
      showing = showings.find_by_asset_id(id)
      showing.insert_at(index + 1)
    end
  end

  private

  # can either be called with an asset or params used to build an asset.
  def check_type!(asset)
    asset = Asset.build(asset) unless asset.respond_to? :is_image?
    raise ErrorMessage.new(I18n.t(:file_must_be_image_error)) unless asset.is_image?
  end

  def assure_page(asset)
    if asset.page
      raise PermissionDenied if asset.page != self
    else
      add_attachment! asset
    end
  end
end
