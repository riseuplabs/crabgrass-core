require 'javascript_integration_test'

class LoginTest < JavascriptIntegrationTest

  def test_login_popup
    visit '/public_group_everyone_can_see'
    click_link 'Sign In'
    login
    logout
  end

end
