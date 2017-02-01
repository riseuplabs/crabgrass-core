require 'test_helper'

# Unit test for basic asset functionality.
#
# See test/unit/asset/* for more specific tests
# and test/integration/asset_test for integration with crabgrass-media
#

class AssetTest < ActiveSupport::TestCase
  def setup
    super
    setup_assets
  end

  def teardown
    teardown_assets
    super
  end

  def test_associations
    assert check_associations(Asset)
  end

  def test_simple_upload
    @asset = FactoryBot.create :png_asset
    assert File.exist?(@asset.private_filename), 'the private file should exist'
    assert read_file('image.png') == File.read(@asset.private_filename),
      'full_filename should be the uploaded_data'
  end

  def test_single_table_inheritance
    @asset = FactoryBot.create :png_asset
    assert_equal 'Png', @asset.type, 'initial asset should be a png'
    assert_equal 'image/png', @asset.content_type,
      'initial asset should be a png'

    @asset.uploaded_data = upload_data('photo.jpg')
    @asset.save
    assert_equal 'Image', @asset.type, 'then the asset should be a jpg'
    assert_equal 'image/jpeg', @asset.content_type,
      'then the asset should be a jpg'
  end

  def test_rename
    @asset = FactoryBot.create :png_asset
    @asset.base_filename = 'newimage'
    @asset.save

    path = format '%s/0000/%04d/', ASSET_PRIVATE_STORAGE, @asset.id

    assert_equal path + 'newimage.png', @asset.private_filename
    assert File.exist?(path + 'newimage.png')
    refute File.exist?(path + 'image.png')
  end

  def test_file_cleanup_on_destroy
    @asset = FactoryBot.create :png_asset
    @asset.update_access
    @asset.destroy

    assert !File.exist?(@asset.private_filename),
      'private file should not exist'
    assert !File.exist?(File.dirname(@asset.private_filename)),
      'dir for private file should not exist'
    assert !File.exist?(@asset.public_filename),
      'public file should not exist'
  end

  def test_build_asset
    asset = Asset.build(uploaded_data: upload_data('photo.jpg'))
    asset.valid? # running validations will load metadata
    assert asset.filename.present?
  end

  def test_empty_files_get_filename
    asset = Asset.build(uploaded_data: upload_data('empty.jpg'))
    assert asset.valid?
    assert asset.filename.present?
  end
end
