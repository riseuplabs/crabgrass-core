require 'test_helper'

class AssetPageTest < ActiveSupport::TestCase


  # fixes fixture_file_upload for Rails 2.3
  include ActionDispatch::TestProcess

  def setup
    setup_assets
    @page = AssetPage.build! title: 'hi', user: users(:blue)
    @asset = Asset.build(uploaded_data: upload_data('photo.jpg'))
    @page.data = @asset
    @page.save!
  end

  def teardown
    teardown_assets
  end

  def test_asset_page_data
    assert_equal @asset, @page.data
    @asset.reload
    assert @asset.page_terms
    assert "1", @page.data.page_terms.media
  end

  def test_asset_page_access
    assert File.exist?(@asset.private_filename)
    assert !File.exist?(@asset.public_filename),
      'public file "%s" should NOT exist' % @asset.public_filename
  end

  def test_asset_page_public_access
    @page.public = true
    @page.save
    assert File.exist?(@asset.public_filename),
      'public file "%s" not created when page became public' % @asset.public_filename
  end

  def test_asset_page_unpublished
    @page.public = true
    @page.save
    @page.public = false
    @page.save
    assert !File.exist?(@asset.public_filename),
      'public file "%s" still present after page was hidden' % @asset.public_filename
  end

  def test_symlinks_untouched_on_unrelated_updates
    @asset.expects(:update_access).never
    @page.title = "new title"
    @page.save
  end

  protected

  def debug
    puts `find #{ASSET_PRIVATE_STORAGE}` if true
  end
end
