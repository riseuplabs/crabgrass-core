require_relative '../../../../test/test_helper'

class GalleryTest < ActionController::IntegrationTest
  def test_create_gallery_with_images
    login 'purple'

    visit '/me/pages'
    click_link I18n.t(:contribute_content_link)
    click_link 'Gallery'

    # within is not necessary (since the fields names are unique)
    # but is here as an example of how to restrict the scope of actions on a page
    within(".create_page table.form") do |scope|
      scope.fill_in 'Title', :with => 'my pictures'

      scope.select 'rainbow', :from => 'Page Owner'
    end
    click_button 'Create Page »'

    assert_contain 'my pictures'
  end
end
