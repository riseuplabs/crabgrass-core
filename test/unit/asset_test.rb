require_relative 'test_helper'

class AssetTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    setup_assets
  end

  def teardown
    teardown_assets
  end

  def test_associations
    assert check_associations(Asset)
    assert check_associations(Asset::Version)
    assert check_associations(Thumbnail)
  end

  def test_paths
    @asset = FactoryGirl.create :png_asset

    assert_equal "%s/0000/%04d/image.png" % [ASSET_PRIVATE_STORAGE,@asset.id], @asset.private_filename
    assert_equal "%s/0000/%04d/image_small.png" % [ASSET_PRIVATE_STORAGE,@asset.id], @asset.private_thumbnail_filename(:small)

    assert_equal "%s/%s/image.png" % [ASSET_PUBLIC_STORAGE,@asset.id], @asset.public_filename
    assert_equal "%s/%s/image_small.png" % [ASSET_PUBLIC_STORAGE,@asset.id], @asset.public_thumbnail_filename(:small)

    assert_equal "/assets/%s/image.png" % @asset.id, @asset.url
    assert_equal "/assets/%s/image_small.png" % @asset.id, @asset.thumbnail_url(:small)
  end

  def test_single_table_inheritance
    @asset = FactoryGirl.create :png_asset
    assert_equal 'PngAsset', @asset.type, 'initial asset should be a png'
    assert_equal 'image/png', @asset.content_type, 'initial asset should be a png'

    @asset.uploaded_data = upload_data('photo.jpg')
    @asset.save
    assert_equal 'ImageAsset', @asset.type, 'then the asset should be a jpg'
    assert_equal 'image/jpeg', @asset.content_type, 'then the asset should be a jpg'
  end

  def test_versions
    @asset = FactoryGirl.create :png_asset
    @id = @asset.id
    @filename_for_1 = @asset.private_filename
    assert_equal 1, @asset.version, 'should be on version 1'

    @asset.uploaded_data = upload_data('photo.jpg')
    @asset.save
    @filename_for_2 = @asset.private_filename
    assert_equal 2, @asset.version, 'should be on version 2'
    assert_equal 2, @asset.versions.size, 'there should be two versions'

    assert !File.exists?(@filename_for_1), 'first non-version file should not exist'
    assert File.exists?(@filename_for_2), 'second non-version file should exist'

    @version = @asset.versions.earliest
    assert_equal @version.class, Asset::Version
    assert_equal 'PngAsset', @version.versioned_type
    assert_equal 'image.png', @version.filename

    #puts @version.inspect
    #puts @version.thumbdefs.inspect
    #puts @version.thumbnail_filename(:small)
    assert_equal 'image_small.png', @version.thumbnail_filename(:small)
    assert_equal "/assets/#{@id}/versions/1/image.png", @version.url
    assert read_file('image.png') == File.read(@version.private_filename), 'version 1 data should match image.png'

    @version = @asset.versions.latest
    assert_equal 'ImageAsset', @version.versioned_type
    assert_equal 'photo.jpg', @version.filename
    assert_equal 'photo_small.jpg', @version.thumbnail_filename(:small)
    assert_equal "/assets/#{@id}/versions/2/photo.jpg", @version.url
    assert read_file('photo.jpg') == File.read(@version.private_filename), 'version 2 data should match photo.jpg'
  end

  def test_rename
    @asset = FactoryGirl.create :png_asset
    @asset.base_filename = 'newimage'
    @asset.save

    assert_equal "%s/0000/%04d/newimage.png" % [ASSET_PRIVATE_STORAGE,@asset.id], @asset.private_filename
    assert File.exists?(@asset.private_filename)
    assert !File.exists?("%s/0000/%04d/image.png" % [ASSET_PRIVATE_STORAGE,@asset.id])
  end

  def test_file_cleanup_on_destroy
    @asset = FactoryGirl.create :png_asset
    @asset.update_access
    @asset.destroy

    assert !File.exists?(@asset.private_filename), 'private file should not exist'
    assert !File.exists?(File.dirname(@asset.private_filename)), 'dir for private file should not exist'
    assert !File.exists?(@asset.public_filename), 'public file should not exist'
  end

  def test_access
    @asset = FactoryGirl.create :png_asset
    assert @asset.public?
    @asset.update_access

    assert File.exists?(@asset.public_filename), 'public file "%s" should exist' % @asset.public_filename
    assert File.symlink?(File.dirname(@asset.public_filename)), 'dir of public file should be a symlink'
    @asset.instance_eval do
      def public?
        false
      end
    end
    @asset.update_access
    assert !File.exists?(@asset.public_filename), 'public file should NOT exist'
    assert !File.symlink?(File.dirname(@asset.public_filename)), 'dir of public file should NOT be a symlink'
  end

  def test_thumbnails
    start_thumb_count = Thumbnail.count
    @asset = FactoryGirl.create :image_asset
    assert @asset.thumbdefs.any?, 'asset should have thumbdefs'
    assert @asset.thumbnails.any?, 'asset should have thumbnail objects'

    @asset.generate_thumbnails

    @thumb1 = @asset.private_thumbnail_filename(:small)
    @thumb_v1 = @asset.versions.latest.private_thumbnail_filename(:small)
    assert File.exists?(@thumb1), '%s should exist' % @thumb1
    assert File.exists?(@thumb_v1), '%s should exist' % @thumb_v1

    @asset.uploaded_data = upload_data('image.png')
    @asset.save
    @asset = Asset.find(@asset.id)

    assert_equal 3, @asset.thumbnails.length, 'there should be three thumbnails'
    assert_equal 2, @asset.versions.length, 'there should be two versions'
    @asset.versions.each do |version|
      assert_equal 3, version.thumbnails.length, 'each version should have thumbnails'
    end

    @asset.generate_thumbnails
    @thumb2 = @asset.private_thumbnail_filename(:small)
    @thumb_v2 = @asset.versions.latest.private_thumbnail_filename(:small)

    assert File.exists?(@thumb2), '%s should exist (new thumb)' % @thumb2
    assert File.exists?(@thumb_v2), '%s should exist (new versioned thumb)' % @thumb_v2
    assert !File.exists?(@thumb1), '%s should NOT exist (old filename)' % @thumb1

    end_thumb_count = Thumbnail.count
    assert_equal start_thumb_count+9, end_thumb_count, 'there should be exactly 9 more thumbnail objects'
  end

  def test_type_changes
    @asset = FactoryGirl.create :image_asset
    assert_equal 'ImageAsset', @asset.type
    assert_equal 3, @asset.thumbnails.count

    # change to TextAsset
    @asset.uploaded_data = upload_data('msword.doc')
    @asset.save
    assert_equal 'application/msword', @asset.content_type
    assert_equal 'TextAsset', @asset.type
    assert_equal 5, @asset.thumbnails.count

    # change back
    @asset = Asset.find(@asset.id)
    @asset.uploaded_data = upload_data('gears.jpg')
    @asset.save
    assert_equal 'ImageAsset', @asset.type
    assert_equal 3, @asset.thumbnails.count
  end

  def test_simple_upload
   @asset = FactoryGirl.create :png_asset
   assert File.exists?( @asset.private_filename ), 'the private file should exist'
   assert read_file('image.png') == File.read(@asset.private_filename), 'full_filename should be the uploaded_data'
  end

  def test_dimensions
    if !GraphicsMagickTransmogrifier.new.available?
      puts "\GraphicMagick converter is not available. Either GraphicMagick is not installed or it can not be started. Skipping AssetTest#test_dimensions."
      return
    end
    @asset = FactoryGirl.create :small_image_asset
    assert_equal 64, @asset.width, 'width must match file'
    assert_equal 64, @asset.height, 'height must match file'
    @asset.uploaded_data = upload_data('bee.jpg')
    @asset.save
    assert_equal 333, @asset.width, 'width must match after new upload'
    assert_equal 500, @asset.height, 'height must match after new upload'

    assert_equal 43, @asset.thumbnail(:small).width, 'guess width should match actual'
    assert_equal 64, @asset.thumbnail(:small).height, 'guess height should match actual'

    @asset.generate_thumbnails
    assert_equal 43, @asset.thumbnail(:small).width, 'actual width should be 43'
    assert_equal 64, @asset.thumbnail(:small).height, 'actual height should be 64'

    assert_equal 43, @asset.versions.latest.thumbnail(:small).width, 'actual width of versioned thumb should be 43'
    assert_equal 64, @asset.versions.latest.thumbnail(:small).height, 'actual height of versioned thumb should be 64'

  end

  def test_doc
    # must have OO installed
    if !LibreOfficeTransmogrifier.new.available?
      skip "OpenOffice converter is not available. Either OpenOffice is not installed or it can not be started. Skipping AssetTest#test_doc."
      return
    end

    # must have GM installed
    if !GraphicsMagickTransmogrifier.new.available?
      skip "GraphicMagick converter is not available. Either GraphicMagick is not installed or it can not be started. Skipping AssetTest#test_doc."
      return
    end

    @asset = Asset.create_from_params :uploaded_data => upload_data('msword.doc')
    assert_equal TextAsset, @asset.class, 'asset should be a TextAsset'
    assert_equal 'TextAsset', @asset.versions.earliest.versioned_type, 'version should by of type TextAsset'

    @asset.generate_thumbnails
    @asset.thumbnails.each do |thumb|
      assert_equal false, thumb.failure?, 'generating thumbnail "%s" should have succeeded' % thumb.name
      assert thumb.private_filename, 'thumbnail "%s" should exist' % thumb.name
    end
  end

  def test_binary
    @asset = Asset.create_from_params :uploaded_data => upload_data('raw_file.bin')
    assert_equal Asset, @asset.class, 'asset should be an Asset'
    assert_equal 'Asset', @asset.versions.earliest.versioned_type, 'version should by of type Asset'
  end

  def test_failure_on_corrupted_file
    Media::Transmogrifier.suppress_errors = true
    @asset = Asset.create_from_params :uploaded_data => upload_data('corrupt.jpg')
    @asset.generate_thumbnails
    @asset.thumbnails.each do |thumb|
      assert_equal true, thumb.failure?, 'generating the thumbnail should have failed'
    end
    Media::Transmogrifier.suppress_errors = false
  end

  def test_failure
    GraphicsMagickTransmogrifier.send(:define_method, :gm_command, proc { false })
    Media::Transmogrifier.suppress_errors = true
    @asset = Asset.create_from_params :uploaded_data => upload_data('photo.jpg')
    @asset.generate_thumbnails
    @asset.thumbnails.each do |thumb|
      assert_equal true, thumb.failure?, 'generating the thumbnail should have failed'
    end
    GraphicsMagickTransmogrifier.send(:define_method, :gm_command, proc { GRAPHICSMAGICK_COMMAND })
    Media::Transmogrifier.suppress_errors = false
  end

  def test_content_type
    assert_equal 'application/octet-stream', Asset.new.content_type
  end

  # data without a file upload, but just from memory
  def test_direct_data
    data1 = '<b>this is some very interesting data</b>'
    data2 = '<i>but not this</i>'

    asset = Asset.create!(:data => '<b>this is some very interesting data</b>', :content_type => 'text/html', :filename => 'data')
    assert_equal data1, File.read(asset.private_filename)

    asset.data = data2
    asset.save

    assert_equal data2, File.read(asset.private_filename)
    assert_equal data1, File.read(asset.versions.earliest.private_filename)
  end

  def test_user_versions
    asset = Asset.create! :data => 'hi', :filename => 'x'
    asset.update_attributes :data => 'bye', :user => users(:blue)
    assert_nil asset.versions.first.user
    assert_equal users(:blue), asset.versions.last.user
  end

  def test_build_asset
    asset = Asset.build(:uploaded_data => upload_data('photo.jpg'))
    asset.valid? # running validations will load metadata
    assert asset.filename.present?
  end

  def test_search
    user = users(:kangaroo)
    correct_ids = Asset.find(:all).collect do |asset|
      asset.page_terms = asset.page.page_terms
      asset.save
      asset.id if user.may?(:view, asset.page)
    end.compact.sort
    ids = Asset.visible_to(user).media_type(:image).find(:all).collect{|asset| asset.id}
    assert_equal correct_ids, ids.sort
  end

  protected

  def debug
    puts `find #{ASSET_PRIVATE_STORAGE}` if true
  end
end
