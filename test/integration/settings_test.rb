require 'integration_test'

class SettingsTest < IntegrationTest
  def test_change_profile
    @user = users(:blue)
    login
    click_on 'Settings'
    click_on 'Profile'
    fill_in 'profile[organization]', with: 'Colors'
    click_on 'Save'
    assert_content 'Your profile has been saved'
    assert_selector 'input[name="profile[organization]"][value="Colors"]'
  end
end
