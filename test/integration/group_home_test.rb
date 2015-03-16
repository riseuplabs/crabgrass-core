require 'integration_test'

class GroupHomeTest < IntegrationTest

  def test_visit_own_group
    @user = users(:blue)
    login
    visit '/animals'
    assert_landing_page groups(:animals)
  end


end
