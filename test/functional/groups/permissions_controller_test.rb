require File.dirname(__FILE__) + '/../../test_helper'

class Groups::PermissionsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user! @user
  end

  def test_index
    login_as @user
    assert_permission :may_list_groups_permissions? do
      get :index, :group_id => @group.to_param
    end
    assert_response :success
  end

  def test_update
    login_as @user
    assert_permission :may_edit_groups_permissions? do
      post :update, :group_id => @group.to_param, :view => true, :id => 0
    end
    assert_response :success
  end

end
