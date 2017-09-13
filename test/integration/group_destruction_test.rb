require 'integration_test'

class GroupDestructionTest < IntegrationTest
  def test_visit_own_group
    @user = users(:blue)
    login
    visit '/animals'
    click_on 'Settings'
    click_on 'Structure'
    click_on 'Destroy animals'
    assert_content 'Request to Destroy Group was sent to animals'
    assert_no_content 'Approve'
    logout
    @user = users(:penguin)
    login
    click_on 'Show Request'
    click_on 'Approve'
    click_on 'Groups'
    assert_no_content 'animals'
  end
end
