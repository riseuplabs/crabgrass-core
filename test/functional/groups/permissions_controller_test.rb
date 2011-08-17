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
    get :index, :group_id => @group.id
    assert_response :success
  end

  def test_index_no_access
    login_as @other_user
    assert_permission_denied do
      get :index, :group_id => @group.id
    end
  end

end
