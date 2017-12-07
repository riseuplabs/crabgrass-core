require 'integration_test'

class PersonTest < IntegrationTest
  def test_visit_friend
    @user = users(:blue)
    login
    visit '/red'
    assert_profile_page users(:red)
    click_on 'Pages'
    assert_content 'Active Filters'
    # pages do not get loaded here due to missing js
  end
end
