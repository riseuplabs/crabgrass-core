module AssetTestHelper
  include ActionDispatch::TestProcess # fixture_file_upload

  ##
  ## ASSET HELPERS
  ##

  def upload_data(file)
    type = 'image/png' if file =~ /\.png$/
    type = 'image/jpeg' if file =~ /\.jpg$/
    type = 'application/msword' if file =~ /\.doc$/
    type = 'application/octet-stream' if file =~ /\.bin$/
    type = 'application/zip' if file =~ /\.zip$/
    fixture_file_upload('files/'+file, type)
  end

  def upload_avatar(file)
    MockFile.new(RAILS_ROOT + '/test/fixtures/files/' + file)
  end

  def read_file(file)
    File.read( RAILS_ROOT + '/test/fixtures/files/' + file )
  end

  def setup_assets
    Media::Transmogrifier.verbose = false  # set to true to see all the commands being run.
    FileUtils.mkdir_p(ASSET_PRIVATE_STORAGE)
    FileUtils.mkdir_p(ASSET_PUBLIC_STORAGE)
    #Conf.disable_site_testing
  end

  def teardown_assets
    FileUtils.rm_rf(ASSET_PRIVATE_STORAGE)
    FileUtils.rm_rf(ASSET_PUBLIC_STORAGE)
  end

end
