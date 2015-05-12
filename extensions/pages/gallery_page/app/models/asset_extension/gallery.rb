module AssetExtension
  module Gallery
    extend ActiveSupport::Concern

    included do
      has_many :showings, dependent: :destroy
      has_many :galleries, through: :showings

      after_save :update_galleries
    end

    def change_source_file(data)
      if Asset.mime_type_from_data(data) !~ /image|pdf/
        raise StandardError.new(I18n.t(:file_must_be_image_error))
      end
      self.uploaded_data = data
      self.save!
    end

    # update galleries after an image was saved which has galleries.
    # the updated_at column of galleries needs to be up to date to allow the
    # download_gallery action to find out if it's cached zips are up to date.
    #
    # hmm... i don't think this is a good idea. it will result in the Gallery page
    # being marked as updated in the recent pages feed, even when it has not been.
    # -elijah

    def update_galleries
      if galleries.any?
        galleries.each { |g| g.save }
      end
    end

  end

end
