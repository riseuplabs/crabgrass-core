# encoding: UTF-8
require 'javascript_integration_test'

class GalleryTest < JavascriptIntegrationTest
  include Integration::Navigation

  def test_create_gallery_with_images
    login
    create_page :gallery,  title: 'my pictures'
    assert_content 'my pictures'
    attach_file_to_hidden 'upload-input', fixture_file('photo.jpg')
    assert_content 'photo'
    attach_file_to_hidden 'upload-input', fixture_file('beé.jpg')
    assert_content 'beé'
    click_page_tab 'Show'
    first('.control_asset_image .thumbnail').click
    assert_content 'Image 1 of 2'
    find('a.right_16').click
    assert_content 'Image 2 of 2'
    assert_image_file 'be%C3%A9_large.jpg'
    find('a.sort_up_16').click
    assert_no_content 'Image'
    # assert_content 'Click thumbnail to see full image.'
  end


  def assert_image_file(filename)
    src = find('.gallery-item img')['src']
    assert_equal filename, src.split('/').last
  end
end
