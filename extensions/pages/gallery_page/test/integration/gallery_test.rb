require 'test_helper'

class GalleryTest < IntegrationTest
  def test_create_gallery_with_images
    login

    visit '/me/pages'
    click_link I18n.t(:contribute_content_link)
    click_link 'Gallery'

    fill_in 'Title', :with => 'my pictures'
    select 'rainbow', :from => 'Page Owner'
    click_button 'Create Page'

    assert_contain 'my pictures'
  end
end
