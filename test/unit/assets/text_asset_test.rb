require 'test_helper'

class TextAssetTest < ActiveSupport::TestCase

  def test_asset_type_from_file
    @asset = Asset.create_from_params uploaded_data: upload_data('msword.doc')
    assert_equal TextAsset, @asset.class, 'asset should be a TextAsset'
    assert_equal 'TextAsset', @asset.versions.earliest.versioned_type,
      'version should by of type TextAsset'
  end

  # test the creation of the thumbnail records according to the defs.
  # Main thing is content_type and filename as they are use to create the
  # actual file later on.
  def test_thumbnail_creation
    @asset = Asset.create_from_params uploaded_data: upload_data('msword.doc')
    thumbnails = @asset.thumbnails

    assert thumbnails.any?, 'asset should have thumbnail objects'
    assert_equal 6, thumbnails.count, 'there should be three thumbnails'
    names = [:small, :medium, :large]
    assert names.none? {|name| @asset.thumbnail_exists?(name)}
    names.each do |name|
      thumbdef = @asset.thumbdefs[name]
      thumbnail = @asset.thumbnail(name)
      assert_equal thumbdef.mime_type, thumbnail.content_type
      assert_equal @asset.thumbnail_filename(thumbdef), thumbnail.filename
    end
  end

  def test_thumbnail_dependencies
    @asset = Asset.create_from_params uploaded_data: upload_data('msword.doc')
    assert_equal @asset.thumbnail(:pdf), @asset.thumbnail(:large).depends_on
    assert_equal @asset.thumbnail(:large), @asset.thumbnail(:medium).depends_on
    assert_equal @asset.thumbnail(:large), @asset.thumbnail(:small).depends_on
  end
end
