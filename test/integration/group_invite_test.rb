require 'integration_test'

class GroupInviteTest < IntegrationTest

  def test_invite_new_via_email
    @group = groups(:animals)
    @request = RequestToJoinUsViaEmail.create created_by: users(:blue),
      email: 'sometest@email.test',
      requestable: @group
    visit "/me/requests/#{@request.id}?code=#{@request.code}"
    signup
    click_on 'Approve'
    assert @group.memberships.where(user_id: @user).exists?
    assert_content @group.display_name
  end

  def test_invite_existing_user_via_email
    @group = groups(:animals)
    @request = RequestToJoinUsViaEmail.create created_by: users(:blue),
      email: 'sometest@email.test',
      requestable: @group
    visit "/me/requests/#{@request.id}?code=#{@request.code}"
    login
    click_on 'Approve'
    assert @group.memberships.where(user_id: @user).exists?
    assert_content @group.display_name
  end
end
