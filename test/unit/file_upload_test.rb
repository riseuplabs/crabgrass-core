require_relative 'test_helper'

class FileUploadTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    setup_assets
  end

  def teardown
    teardown_assets
  end

  def test_classic_file_upload
    file_to_upload = upload_data('photo.jpg')
    @asset = Asset.create_from_params uploaded_data: file_to_upload
  end

  def test_smaller_file_upload
    file_to_upload = upload_data('gears.jpg')
    @asset = Asset.create_from_params uploaded_data: file_to_upload
  end

  def test_file_upload_that_used_to_work
    file_to_upload = upload_data('image.png')
    @asset = Asset.create_from_params uploaded_data: file_to_upload
    assert File.exist?( @asset.private_filename ), 'the private file should exist'
  end

  def test_using_factory_girl_instead
    @asset = FactoryGirl.create :image_asset
    assert_equal 'ImageAsset', @asset.class.name
    assert File.exist?( @asset.private_filename ), 'the private file should exist'
    assert_equal 500, @asset.height
    assert_equal 333, @asset.width
    assert_equal "bee.jpg", @asset.filename
    assert_equal 100266, @asset.size
    assert @asset.is_image
  end

end

