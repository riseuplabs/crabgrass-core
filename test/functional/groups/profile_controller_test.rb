require File.dirname(__FILE__) + '/../../test_helper'

class Groups::ProfileControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user! @user
  end

  def test_edit
    login_as @user
    assert_permission :may_edit_groups_profile? do
      get :edit, :group_id => @group.to_param
    end
    assert_response :success
  end

  def test_update
    login_as @user
    assert_permission :may_edit_groups_profile? do
      post :update, :group_id => @group.to_param,
        :profile => {}
    end
    assert_response :redirect
  end

end
