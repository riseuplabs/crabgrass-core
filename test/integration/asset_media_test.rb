require 'test_helper'

# Test the integration of crabgrass-media with asset uploads
# and thumbnail creation.
#
# This is an integration test for the models.
#

class Asset_Media_Test < ActiveSupport::TestCase
  def setup
    setup_assets
  end

  def teardown
    teardown_assets
  end

  def test_access
    asset = FactoryBot.create :png_asset
    assert asset.public?
    asset.update_access

    assert File.exist?(asset.public_filename), format('public file "%s" should exist', asset.public_filename)
    assert File.symlink?(File.dirname(asset.public_filename)), 'dir of public file should be a symlink'
    asset.instance_eval do
      def public?
        false
      end
    end
    asset.update_access
    assert !File.exist?(asset.public_filename), 'public file should NOT exist'
    assert !File.symlink?(File.dirname(asset.public_filename)), 'dir of public file should NOT be a symlink'
  end

  def test_thumbnail_integration
    start_thumb_count = Thumbnail.count
    asset = FactoryBot.create :image_asset
    asset.generate_thumbnails

    thumb_file = asset.thumbnail_filename(:small)
    thumb1 = asset.private_filename thumb_file
    thumb_v1 = asset.versions.latest.private_filename thumb_file
    assert File.exist?(thumb1), format('%s should exist', thumb1)
    assert File.exist?(thumb_v1), format('%s should exist', thumb_v1)

    asset.uploaded_data = upload_data('image.png')
    asset.save
    asset = Asset.find(asset.id)

    assert_equal 3, asset.thumbnails.length, 'there should be three thumbnails'
    assert_equal 2, asset.versions.length, 'there should be two versions'
    asset.versions.each do |version|
      assert_equal 3, version.thumbnails.length, 'each version should have thumbnails'
    end

    asset.generate_thumbnails
    thumb_file = asset.thumbnail_filename(:small)
    thumb2 = asset.private_filename thumb_file
    thumb_v2 = asset.versions.latest.private_filename thumb_file

    assert File.exist?(thumb2), format('%s should exist (new thumb)', @thumb2)
    assert File.exist?(thumb_v2), format('%s should exist (new versioned thumb)', @thumb_v2)
    assert !File.exist?(thumb1), format('%s should NOT exist (old filename)', @thumb1)

    end_thumb_count = Thumbnail.count
    assert_equal start_thumb_count + 9, end_thumb_count, 'there should be exactly 9 more thumbnail objects'
  end

  def test_type_changes
    asset = FactoryBot.create :image_asset
    word_asset = FactoryBot.create :word_asset
    assert_equal 'Image', asset.type
    assert_equal 3, asset.thumbnails.count

    # change to Text
    asset.uploaded_data = upload_data('msword.doc')
    asset.save
    assert_equal 'application/msword', asset.content_type
    assert_equal 'Text', asset.type
    # relative comparison to account for CI which does not have
    # a transmogrifier for word right now.
    assert_equal word_asset.thumbnails.count, asset.thumbnails.count

    # change back
    asset = Asset.find(asset.id)
    asset.uploaded_data = upload_data('gears.jpg')
    asset.save
    assert_equal 'Image', asset.type
    assert_equal 3, asset.thumbnails.count
  end

  def test_thumbnail_size_after_new_upload
    asset = FactoryBot.create :small_image_asset
    assert_equal 64, asset.width, 'width must match file'
    assert_equal 64, asset.height, 'height must match file'
    asset.uploaded_data = upload_data('bee.jpg')
    asset.save
    assert_equal 333, asset.width, 'width must match after new upload'
    assert_equal 500, asset.height, 'height must match after new upload'
  end

  def test_thumbnail_size_guess
    asset = FactoryBot.create :image_asset
    assert_equal 333, asset.width, 'width must match after new upload'
    assert_equal 500, asset.height, 'height must match after new upload'
    assert_equal 43, asset.thumbnail(:small).width, 'guess width should match actual'
    assert_equal 64, asset.thumbnail(:small).height, 'guess height should match actual'
  end

  def test_dimension_integration
    skip_if_missing :GraphicsMagick
    asset = FactoryBot.create :image_asset
    asset.generate_thumbnails
    assert_equal 43, asset.thumbnail(:small).width, 'actual width should be 43'
    assert_equal 64, asset.thumbnail(:small).height, 'actual height should be 64'

    assert_equal 43, asset.versions.latest.thumbnail(:small).width, 'actual width of versioned thumb should be 43'
    assert_equal 64, asset.versions.latest.thumbnail(:small).height, 'actual height of versioned thumb should be 64'

    assert_equal %w[43 64], Media.dimensions(asset.thumbnail(:small).private_filename)
    assert_equal %w[133 200], Media.dimensions(asset.thumbnail(:medium).private_filename)
  end

  def test_odt_integration
    skip_if_missing :LibreOffice

    asset = Asset.create_from_params uploaded_data: upload_data('test.odt')
    assert_equal 'Asset::Doc', asset.class.name
    asset.generate_thumbnails

    # pdf's are the basis for the other thumbnails. So let's check that first.
    assert_thumb_exists asset, 'pdf'
  end

  def test_doc_integration
    skip_if_missing :LibreOffice

    asset = Asset.create_from_params uploaded_data: upload_data('msword.doc')
    assert_equal 'Asset::Text', asset.class.name
    asset.generate_thumbnails

    # pdf's are the basis for the other thumbnails. So let's check that first.
    assert_thumb_exists asset, 'pdf'
  end

  def test_binary
    asset = Asset.create_from_params uploaded_data: upload_data('raw_file.bin')
    assert_equal Asset, asset.class, 'asset should be an Asset'
    assert_equal 'Asset', asset.versions.earliest.versioned_type,
      'version should by of type Asset'
  end

  def test_failure_on_corrupted_file
    asset = Asset.create_from_params uploaded_data: upload_data('corrupt.jpg')
    asset.generate_thumbnails
    asset.thumbnails.each do |thumb|
      assert thumb.failure?, 'generating the thumbnail should have failed'
    end
  end

  # we currently do not have a xcf transmogrifier
  def test_no_thumbs_for_xcf
    asset = Asset.create_from_params uploaded_data: upload_data('image.xcf')
    asset.generate_thumbnails
    assert_equal Asset::Image, asset.class
    assert_equal 0, asset.thumbnails.count
  end

  def test_content_type
    assert_equal 'application/octet-stream', Asset.new.content_type
  end

  def test_search
    user = users(:kangaroo)
    correct_ids = Asset.all.map do |asset|
      asset.page_terms = asset.page.page_terms
      asset.save
      asset.id if user.may?(:view, asset.page)
    end.compact.sort
    ids = Asset.visible_to(user).media_type(:image).pluck(:id)
    assert_equal correct_ids, ids.sort
  end

  protected

  def skip_if_missing(transmogrifier)
    klass = "Media::#{transmogrifier}Transmogrifier".constantize
    return if klass.available?
    skip <<-EOM
    #{transmogrifier} converter is not available.
    This is most likely due to missing dependencies.
    EOM
  end

  def transmogrifier_for(options = {})
    Media::Transmogrifier.stubs(:new).with(all_of(
                                             has_key(:input_file),
                                             has_key(:output_file),
                                             has_entries(options)
    ))
  end

  def assert_thumb_exists(asset, thumb)
    name = asset.thumbnail_filename(thumb)
    assert asset.thumbnail_exists?(thumb),
           "Could not find #{asset.private_filename(name)}"
  end
end
