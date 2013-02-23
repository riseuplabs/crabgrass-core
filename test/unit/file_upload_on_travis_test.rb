require_relative 'test_helper'

class AssetTest < ActiveSupport::TestCase
  # fixture_file_upload for Rails 3:
  include ActionDispatch::TestProcess
  fixtures :all

  def setup
    setup_assets
  end

  def teardown
    teardown_assets
  end

  def test_classic_file_upload_that_failed
    10.times do
      print ','
      file_to_upload = upload_data('photo.jpg')
      @asset = Asset.create_from_params :uploaded_data => file_to_upload
    end
  end

  def test_slow_file_upload
    10.times do
      print '+'
      file_to_upload = upload_data('photo.jpg')
      sleep 1
      @asset = Asset.create_from_params :uploaded_data => file_to_upload
    end
  end

  def test_smaller_file_upload
    10.times do
      print '`'
      file_to_upload = upload_data('gears.jpg')
      @asset = Asset.create_from_params :uploaded_data => file_to_upload
    end
  end

  def test_file_upload_that_used_to_work
    10.times do
      print ';'
      file_to_upload = upload_data('image.png')
      @asset = Asset.create_from_params :uploaded_data => file_to_upload
      assert File.exists?( @asset.private_filename ), 'the private file should exist'
    end
  end

end

