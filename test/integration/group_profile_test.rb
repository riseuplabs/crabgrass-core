require 'integration_test'

class GroupProfileTest < IntegrationTest
  def setup
    super
    @user = users(:blue)
    login
  end

  def test_editing_profile
    visit '/animals'
    click_on 'Settings'
    click_on 'Profile'
    attach_file 'File', fixture_file('photo.jpg')
    click_on 'Save'
    assert_selector 'div[style*="background"][style*="pictures"]'
    assert_content 'Summary'
  end
end
