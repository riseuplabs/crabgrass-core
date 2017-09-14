require 'test_helper'

class Group::RequestsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group)
    @group.add_user! @user
    login_as @user
  end

  def test_index
    assert_permission :may_admin_group? do
      get :index, group_id: @group.to_param
    end
    assert_response :success
  end

  def test_create
    assert_difference 'RequestToDestroyOurGroup.count' do
      get :create, group_id: @group.to_param, type: 'destroy_group'
    end
    assert_response :redirect
    assert activity = Activity::UserProposedToDestroyGroup.last
    assert_equal @user, activity.user
    assert_equal @group, activity.group
  end

  def test_approve
    @other = FactoryGirl.create(:user)
    @group.add_user! @other
    @req = RequestToCreateCouncil.create! group: @group,
                                          requestable: @group,
                                          created_by: @other

    assert_difference 'Group::Council.count' do
      post :update, group_id: @group.to_param, id: @req.id, mark: :approve
    end
    assert_response :success
  end
end
