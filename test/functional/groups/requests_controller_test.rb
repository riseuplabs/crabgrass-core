require File.dirname(__FILE__) + '/../../test_helper'

class Groups::RequestsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
  end


  def test_index
    @group.add_user! @user
    login_as @user
    assert_permission :may_list_group_requests? do
      get :index, :group_id => @group.to_param
    end
    assert_response :success
  end

  def test_create
    login_as @user
    @group.grant! :public, :request_membership
    assert_permission :may_create_group_request? do
      assert_difference 'RequestToJoinYou.count' do
        get :create, :group_id => @group.to_param
      end
    end
    assert_response :redirect
  end

  def test_update
    @group.add_user! @user
    login_as @user
    requesting = User.make
    request = RequestToJoinYou.create :created_by => requesting,
      :recipient => @group
    assert_permission :may_update_request? do
      get :update, :group_id => @group.to_param,
        :id => request.id
    end
  end

  def test_destroy
    @group.add_user! @user
    login_as @user
    requesting = User.make
    request = RequestToJoinYou.create :created_by => requesting,
      :recipient => @group
    assert_permission :may_destroy_request? do
      assert_difference 'RequestToJoinYou.count', -1 do
        delete :destroy, :group_id => @group.to_param,
         :id => request.id
      end
    end
    assert_response :success
  end
end
