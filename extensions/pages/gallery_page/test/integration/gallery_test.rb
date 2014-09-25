require 'integration_test'

class GalleryTest < IntegrationTest
  def test_create_gallery_with_images
    login
    create_page :gallery,  :title => 'my pictures'
    assert_content 'my pictures'
  end
end
