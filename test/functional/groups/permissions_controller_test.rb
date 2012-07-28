require File.dirname(__FILE__) + '/../../test_helper'

class Groups::PermissionsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @other_user = User.make
    @group = Group.make
    @group.add_user!(@user)
  end

  def test_index
    login_as @user
    assert_permission :may_admin_group? do
      get :index, :group_id => @group.to_param
    end
    assert_response :success
  end

  def test_index_no_access
    login_as @other_user
    assert_permission_denied do
      get :index, :group_id => @group.to_param
    end
  end

  def test_update
    public_code = @controller.send(:key_holders, :public).first.code
    login_as @user
    assert_permission :may_admin_group? do
      post :update,
        :group_id => @group.to_param,
        :id => public_code,
        :gate => 'view',
        :new_state => 'open'
    end
    assert_response :success
    assert @group.has_access?(:view, :public)
  end

end
