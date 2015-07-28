require 'test_helper'

class ImageAssetTest < ActiveSupport::TestCase

  def test_thumbnail_definitions
    @asset = FactoryGirl.build :image_asset
    assert @asset.thumbdefs.any?, 'asset should have thumbdefs'
    assert_equal 3, @asset.thumbdefs.count
  end

  # test the creation of the thumbnail records according to the defs.
  # Main thing is content_type and filename as they are use to create the
  # actual file later on.
  def test_thumbnail_creation
    @asset = FactoryGirl.create :image_asset
    thumbnails = @asset.thumbnails

    assert thumbnails.any?, 'asset should have thumbnail objects'
    assert_equal 3, thumbnails.count, 'there should be three thumbnails'
    sizes = [:small, :medium, :large]
    assert sizes.none? {|size| @asset.thumbnail_exists?(size)}
    sizes.each do |size|
      thumbdef = @asset.thumbdefs[size]
      thumbnail = @asset.thumbnail(size)
      assert_equal thumbdef.mime_type, thumbnail.content_type
      assert_equal @asset.thumbnail_filename(thumbdef), thumbnail.filename
    end
  end

end
