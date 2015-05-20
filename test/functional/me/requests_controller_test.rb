require_relative '../../test_helper'

class Me::RequestsControllerTest < ActionController::TestCase

  fixtures :users, :requests

  def test_destroy
    login_as users(:blue)
    request = RequestToJoinUs.created_by(users(:blue)).find(:first)
    xhr :delete, :destroy, id: request.id
    assert_message /destroyed/i
  end

  def test_index
    login_as users(:blue)
    get :index
    assert_response :success
  end

  def test_update_group_request
    @user  = FactoryGirl.create(:user)
    @group  = FactoryGirl.create(:group)
    @group.add_user! @user
    login_as @user
    requesting = FactoryGirl.create(:user)
    request = RequestToJoinYou.create created_by: requesting,
      recipient: @group
    xhr :post, :update, id: request.id
    assert_response :success
  end

  def test_destroy_group_request
    @user  = FactoryGirl.create(:user)
    @group  = FactoryGirl.create(:group)
    @group.add_user! @user
    login_as @user
    requesting = FactoryGirl.create(:user)
    request = RequestToJoinYou.create created_by: requesting,
      recipient: @group
    assert_difference 'RequestToJoinYou.count', -1 do
      xhr :delete, :destroy, id: request.id
    end
    assert_response :success
  end

  def test_other_requests_hidden
    @user  = FactoryGirl.create(:user)
    login_as @user
    assert_not_found do
      get :show, id: Request.last
    end
  end
end
