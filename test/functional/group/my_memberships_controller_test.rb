require 'test_helper'

class Group::MyMembershipsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
  end

  def test_create
    @group.grant_access! public: %i[join view]
    login_as @user
    assert_permission :may_join_group? do
      assert_difference '@group.users.count' do
        get :create, group_id: @group.to_param
      end
    end
    assert_response :redirect
  end

  def test_destroy
    @group.add_user! @user
    @group.add_user! FactoryBot.create(:user) # make sure there are at least 2 users
    login_as @user
    membership = @group.memberships.find_by_user_id(@user.id)
    assert_permission :may_leave_group? do
      assert_difference '@group.users.count', -1 do
        delete :destroy, group_id: @group.to_param, id: membership.id
      end
    end
    assert_response :redirect
  end
end
