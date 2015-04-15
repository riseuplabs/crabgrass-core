require 'integration_test'

class GroupInviteTest < IntegrationTest

  def test_invited_via_email
    @group = groups(:animals)
    @request = RequestToJoinUsViaEmail.create created_by: users(:blue),
      email: 'sometest@email.test',
      requestable: @group
    visit "/me/requests/#{@request.id}?code=#{@request.code}"
    signup
    click_on 'Approve'
    assert @group.memberships.where(user_id: @user).exists?
  end
end
