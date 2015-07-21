require 'test_helper'

class Groups::MembershipRequestsControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
    @group  = FactoryGirl.create(:group)
    @group.add_user! @user
    login_as @user
  end

  def test_request_to_remove
    @remove_me = FactoryGirl.create(:user)
    @group.add_user! @remove_me
    assert_difference "RequestToRemoveUser.count" do
      post :create, group_id: @group.to_param,
        entity: @remove_me.login,
        type: :destroy
    end
    req = RequestToRemoveUser.last
    assert_response :redirect
    assert_equal @remove_me, req.user
    assert_equal @user, req.created_by
  end

  def test_approve
    @other = FactoryGirl.create(:user)
    @remove_me = FactoryGirl.create(:user)
    @group.add_user! @other
    @group.add_user! @remove_me

    @req = RequestToRemoveUser.create! group: @group,
      user: @remove_me,
      created_by: @other

    assert_difference '@group.users.count', -1 do
      put :update, group_id: @group.to_param, id: @req.id, mark: :approve
    end
    assert_response :success
  end
end
