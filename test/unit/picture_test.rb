require File.dirname(__FILE__) + '/../test_helper'

class PictureTest < ActiveSupport::TestCase

  def setup
    Media::Transmogrifier.verbose = false  # set to true to see all the commands being run.
    FileUtils.mkdir_p(PICTURE_PRIVATE_STORAGE)
    FileUtils.mkdir_p(PICTURE_PUBLIC_STORAGE)
  end

  def teardown
    FileUtils.rm_rf(PICTURE_PRIVATE_STORAGE)
    FileUtils.rm_rf(PICTURE_PUBLIC_STORAGE)
  end

  def test_create
    picture = Picture.create(:upload => upload_data('bee.jpg'))
    assert_not_nil File.read(picture.private_file_path)
  end

  def test_geometry
    geometry = {:max_width => 100, :min_width => 100}
    picture = Picture.create(:upload => upload_data('photo.jpg'))
    picture.add_geometry!(geometry)
    assert_not_nil File.read(picture.private_file_path(geometry))
    assert_equal [100,64], picture.dimensions[[100,100,0,0]]
  end

end
