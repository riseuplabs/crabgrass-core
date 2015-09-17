require 'test_helper'

class Asset::TextTest < ActiveSupport::TestCase

  def test_asset_type_from_file
    @asset = FactoryGirl.create :word_asset
    assert_equal Asset::Text, @asset.class, 'asset should be a Asset::Text'
    assert_equal 'Text', @asset.versions.earliest.versioned_type,
      'version should by of type Asset::Text'
  end

  def test_text_asset_thumb_defs
    @asset = FactoryGirl.build :word_asset
    assert_equal 6, @asset.thumbdefs.count
  end

  def test_text_asset_creates_thumbnails
    @asset = FactoryGirl.build :word_asset
    @asset.expects :create_thumbnail_records
    @asset.save
  end

  def test_only_creates_available_thumbnails
    Media.stub :may_produce?, false do
      @asset = FactoryGirl.create :word_asset
      assert_equal 0, @asset.thumbnails.count
    end
  end

  # test the creation of the thumbnail records according to the defs.
  # Main thing is content_type and filename as they are use to create the
  # actual file later on.
  def test_thumbnail_creation
    # We claim to be able to do all media conversion even if the
    # dependencies are not installed
    Media.stub :may_produce?, true do
      @asset = FactoryGirl.create :word_asset
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
  end

  def test_thumbnail_dependencies
    # We claim to be able to do all media conversion even if the
    # dependencies are not installed
    Media.stub :may_produce?, true do
      @asset = FactoryGirl.create :word_asset
      assert_equal @asset.thumbnail(:pdf), @asset.thumbnail(:large).depends_on
      assert_equal @asset.thumbnail(:large), @asset.thumbnail(:medium).depends_on
      assert_equal @asset.thumbnail(:large), @asset.thumbnail(:small).depends_on
    end
  end
end
