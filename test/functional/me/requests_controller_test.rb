require 'test_helper'

class Me::RequestsControllerTest < ActionController::TestCase
  def test_destroy
    login_as users(:blue)
    request = RequestToJoinUs.created_by(users(:blue)).first
    xhr :delete, :destroy, id: request.id
    assert_message /destroyed/i
  end

  def test_index
    login_as users(:blue)
    get :index
    assert_response :success
  end

  def test_approve_friend_request
    @user = FactoryBot.create(:user)
    requesting = FactoryBot.create(:user)
    request = RequestToFriend.create created_by: requesting,
                                     recipient: @user
    login_as @user
    assert_response :success
  end

  def test_approve_group_request
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user! @user
    login_as @user
    requesting = FactoryBot.create(:user)
    request = RequestToJoinYou.create created_by: requesting,
                                      recipient: @group
    assert_response :success
  end

  def test_destroy_group_request
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user! @user
    login_as @user
    requesting = FactoryBot.create(:user)
    request = RequestToJoinYou.create created_by: requesting,
                                      recipient: @group
    assert_difference 'RequestToJoinYou.count', -1 do
      xhr :delete, :destroy, id: request.id
    end
    assert_response :success
  end

  def test_other_requests_hidden
    @user = FactoryBot.create(:user)
    login_as @user
    assert_not_found do
      get :show, params: { id: Request.last }
    end
  end
end
