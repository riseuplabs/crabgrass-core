require 'test_helper'

class Me::RequestsControllerTest < ActionController::TestCase
  def test_destroy
    login_as users(:blue)
    request = RequestToJoinUs.created_by(users(:blue)).first
    delete :destroy, params: { id: request.id }, xhr: true
    assert_message /destroyed/i
  end

  def test_index
    login_as users(:blue)
    get :index
    assert_response :success
  end

  def test_approve_friend_request
    user = FactoryBot.create(:user)
    requesting = FactoryBot.create(:user)
    request = RequestToFriend.create created_by: requesting,
                                     recipient: user
    login_as user
    xhr :post, :update, id: request.id, mark: 'approve'
    assert_response :success
  end

  def test_approve_group_request
    user = FactoryBot.create(:user)
    group = FactoryBot.create(:group)
    group.add_user! user
    login_as user
    requesting = FactoryBot.create(:user)
    request = RequestToJoinYou.create created_by: requesting,
                                      recipient: group
    xhr :post, :update, id: request.id, mark: 'approve'
    assert_response :success
  end

  def test_dup_group_join_request
    user = FactoryBot.create(:user)
    group = FactoryBot.create(:group)
    group.add_user! user
    login_as user
    requesting = FactoryBot.create(:user)
    request = RequestToJoinYou.create created_by: requesting,
                                      recipient: group
    group.add_user! requesting
    xhr :post, :update, id: request.id, mark: 'approve'
    assert_response :conflict
  end

  def test_dup_remove_from_group_request
    user = FactoryBot.create(:user)
    requesting = FactoryBot.create(:user)
    remove_me = FactoryBot.create(:user)
    group = FactoryBot.create(:group)
    group.add_user! user
    group.add_user! requesting
    group.add_user! remove_me
    request = RequestToRemoveUser.create created_by: requesting,
      recipient: group,
      requestable: remove_me
    login_as user
    group.remove_user! remove_me
    xhr :post, :update, id: request.id, mark: 'approve'
    assert_response :conflict
  end

  def test_destroy_group_request
    user = FactoryBot.create(:user)
    group = FactoryBot.create(:group)
    group.add_user! user
    login_as user
    requesting = FactoryBot.create(:user)
    request = RequestToJoinYou.create created_by: requesting,
                                      recipient: group
    assert_difference 'RequestToJoinYou.count', -1 do
      delete :destroy, params: { id: request.id }, xhr: true
    end
    assert_response :success
  end

  def test_other_requests_hidden
    user = FactoryBot.create(:user)
    login_as user
    assert_not_found do
      get :show, params: { id: Request.last }
    end
  end
end
