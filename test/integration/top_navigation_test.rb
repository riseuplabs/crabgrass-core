require 'integration_test'

class TopNavigationTest < IntegrationTest
  include Integration::Navigation

  def test_me_menu
    login
    entries = {
      'Pages' => 'Active Filters',
      'Messages' => 'Recipient',
      'Settings' => 'Account Settings'
    }
    entries.each do |k, v|
      find('#menu_me').click_on(k, visible: false)
      assert_content v
    end
  end
end
