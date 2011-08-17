require File.dirname(__FILE__) + '/../../test_helper'

class Groups::MembersControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user!(@user)
  end

  def test_index
    login_as @user
    assert_permission :may_list_groups_members? do
      get :index, :group_id => @group.to_param
    end
    assert_response :success
  end

  def test_destroy
    @council = Council.make_for :group => @group
    @council.add_user! @user
    other_user = User.make
    @group.add_user! other_user
    membership = @group.memberships.find_by_user_id(other_user.id)
    login_as @user
    assert_permission :may_destroy_groups_members? do
      delete :destroy, :group_id => @group.to_param, :id => membership.id
    end
    assert_response :success
  end

end
