require_relative 'test_helper'

class AssetPageTest < ActiveSupport::TestCase
  fixtures :users, :assets

  # fixes fixture_file_upload for Rails 2.3
  include ActionDispatch::TestProcess

  def setup
    setup_assets
  end

  def teardown
    teardown_assets
  end

  def test_asset_page
    asset = Asset.build(:uploaded_data => upload_data('photo.jpg'))
    page = nil
    assert_nothing_raised do
      page = AssetPage.create! :title => 'hi', :data => asset, :user => users(:blue)
    end
    assert_equal asset, page.data
    asset.reload
    assert asset.page_terms
    assert "1", page.data.page_terms.media
  end

  def test_asset_page_access
    page = AssetPage.build! :title => 'hi', :user => users(:blue)
    asset = Asset.build(:uploaded_data => upload_data('photo.jpg'))
    page.data = asset
    page.save!
    assert File.exists?(asset.private_filename)
    assert !File.exists?(asset.public_filename), 'public file "%s" should NOT exist' % asset.public_filename
  end

  # make sure assigning page.data later still updates permissions.
  def test_asset_page_alt_method
    page = AssetPage.create! :title => 'perm test', :user => users(:blue)
    asset = Asset.create! :data => 'hi', :filename => 'x'
    page.data = asset
    page.save!
    assert asset.visible?(users(:blue))
  end

  protected

  def debug
    puts `find #{ASSET_PRIVATE_STORAGE}` if true
  end
end
