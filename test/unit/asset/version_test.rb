require 'test_helper'

# Asset Version Unit Test
#
# Test the versioning capabilities of the Asset Model

class Asset::VersionTest < ActiveSupport::TestCase

  def setup
    @asset = FactoryGirl.create :png_asset
  end

  def test_associations
    assert check_associations(Asset::Version)
  end

  def test_initial_version
    assert_equal 1, @asset.version, 'should be on version 1'
  end

  def test_additional_version
    add_version
    assert_equal 2, @asset.version, 'should be on version 2'
    assert_equal 2, @asset.versions.size, 'there should be two versions'
  end

  def test_old_version
    add_version
    @version = @asset.versions.earliest
    assert_equal @version.class, Asset::Version
    assert_equal 'Png', @version.versioned_type
    assert_equal 'image.png', @version.filename
  end

  def test_new_version
    add_version
    @version = @asset.versions.latest
    assert_equal 'Image', @version.versioned_type
    assert_equal 'photo.jpg', @version.filename
    assert_equal 'photo_small.jpg', @version.thumbnail_filename(:small)
    assert_equal "/assets/#{@asset.id}/versions/2/photo.jpg", @version.url
    assert read_file('photo.jpg') == File.read(@version.private_filename),
      'version 2 data should match photo.jpg'
  end

  def test_new_version_replaces_main_file
    @old_filename = @asset.private_filename
    add_version
    @new_filename = @asset.private_filename

    refute File.exist?(@old_filename),
      'old file can only be accessed through version'
    assert File.exist?(@new_filename),
      'current file can be accessed directly through asset'
  end

  def test_user_versions
    asset = Asset.create! uploaded_data: upload_data('empty.jpg')
    asset.update_attributes user: users(:blue),
      uploaded_data: upload_data('photo.jpg')
    assert_nil asset.versions.first.user
    assert_equal users(:blue), asset.versions.last.user
  end

  protected

  def add_version
    @asset.uploaded_data = upload_data('photo.jpg')
    @asset.save
  end

end
