require 'javascript_integration_test'

class GroupSettingsTest < JavascriptIntegrationTest

  fixtures :users, 'group/memberships', :groups, :profiles

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

  def test_changing_committee_name
    visit '/rainbow+the-warm-colors'
    click_on 'Settings'
    fill_in 'group_name', with: 'rainbow+some-warm-colors'
    click_on 'Save'
    assert_content 'Changes saved'
    click_on 'Home'
    click_on 'page owned by the warm colors'
    assert_equal '/rainbow+some-warm-colors/committee_page', current_path
    assert_content 'some-warm-colors'
  end
end
