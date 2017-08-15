module AssetTestHelper
  include ActionDispatch::TestProcess # fixture_file_upload

  ##
  ## ASSET HELPERS
  ##

  def upload_data(file)
    type = 'image/png' if file =~ /\.png\Z/
    type = 'image/jpeg' if file =~ /\.jpg\Z/
    type = 'image/x-xcf' if file =~ /\.xcf\Z/
    type = 'application/msword' if file =~ /\.doc\Z/
    type = 'application/octet-stream' if file =~ /\.bin\Z/
    type = 'application/zip' if file =~ /\.zip\Z/
    fixture_file_upload('files/'+file, type)
  end

  def upload_avatar(file)
    MockFile.new(fixture_file(file))
  end

  def read_file(file)
    fixture_file(file).read
  end

  def fixture_file(file)
    Rails.root + 'test/fixtures/files' + file
  end

  def setup_assets
    # set to true to see all the commands being run.
    Media::Transmogrifier.verbose = false
    FileUtils.mkdir_p(ASSET_PRIVATE_STORAGE)
    FileUtils.mkdir_p(ASSET_PUBLIC_STORAGE)
    #Conf.disable_site_testing
  end

  def teardown_assets
    FileUtils.rm_rf(ASSET_PRIVATE_STORAGE)
    FileUtils.rm_rf(ASSET_PUBLIC_STORAGE)
  end

end
