require 'javascript_integration_test'

class GroupSettingsTest < JavascriptIntegrationTest

  def setup
    super
    @user = users(:blue)
    login
  end

  def test_editing_profile
    visit '/animals'
    click_on 'Settings'
    assert_selector 'img.avatar[src="/avatars/0/large.jpg?0"]'
    click_on 'upload image'
    attach_file 'avatar_image_file', fixture_file('photo.jpg')
    click_on 'Upload Image'
    assert_no_selector 'img.avatar[src="/avatars/0/large.jpg?0"]'
    assert_selector 'img.avatar[src*="/avatars/"][src*="large.jpg"]'
  end

end
