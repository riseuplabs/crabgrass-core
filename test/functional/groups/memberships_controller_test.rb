require File.dirname(__FILE__) + '/../../test_helper'

class Groups::MembershipsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
  end

  def test_create
    @group.grant! :public, :join
    login_as @user
    assert_permission :may_create_groups_membership? do
      assert_difference '@group.users.count' do
        get :create, :group_id => @group.to_param
      end
    end
    assert_response :redirect
  end

  def test_destroy
    @group.add_user! @user
    @group.add_user! User.make   # make sure there are at least 2 users
    login_as @user
    membership = @group.memberships.find_by_user_id(@user.id)
    assert_permission :may_destroy_groups_membership? do
      assert_difference '@group.users.count', -1 do
        delete :destroy, :group_id => @group.to_param, :id => membership.id
      end
    end
    assert_response :redirect
  end

end
