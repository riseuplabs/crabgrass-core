require File.dirname(__FILE__) + '/../../test_helper'

class Groups::RequestsControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
    @group  = FactoryGirl.create(:group)
  end


  def test_index
    @group.add_user! @user
    login_as @user
    assert_permission :may_admin_group? do
      get :index, group_id: @group.to_param
    end
    assert_response :success
  end

  def test_create
    login_as @user
    @group.add_user! @user
      assert_difference 'RequestToDestroyOurGroup.count' do
        get :create, group_id: @group.to_param, type: 'destroy_group'
      end
    assert_response :redirect
    assert activity = UserProposedToDestroyGroupActivity.last
    assert_equal @user, activity.user
    assert_equal @group, activity.group
  end
end
