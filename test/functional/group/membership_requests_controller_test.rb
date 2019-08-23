require 'test_helper'

class Group::MembershipRequestsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    login_as @user
  end

  def test_request_to_join
    @group.grant_access! public: :view
    assert_difference 'RequestToJoinYou.count' do
      post :create, params: { group_id: @group.to_param, type: :join }
    end
    req = RequestToJoinYou.last
    assert_response :redirect
    assert_equal @user, req.user
    assert_equal @group, req.group
  end

  def test_no_dup_request_to_join
    # group which already has members
    @group = groups(:animals)
    @req = RequestToJoinYou.create recipient: @group, created_by: @user
    assert_no_difference 'RequestToJoinYou.count' do
      assert_no_difference 'Notice.count' do
        post :create, params: { group_id: @group.to_param, type: :join }, xhr: true
      end
    end
    assert_response :redirect
  end

  def test_request_to_remove
    @group.add_user! @user
    @remove_me = FactoryBot.create(:user)
    @group.add_user! @remove_me
    assert_difference 'RequestToRemoveUser.count' do
      post :create, params: { group_id: @group.to_param, entity: @remove_me.login, type: :destroy }
    end
    req = RequestToRemoveUser.last
    assert_response :redirect
    assert_equal @remove_me, req.user
    assert_equal @user, req.created_by
  end

  def test_approve
    @group.add_user! @user
    @other = FactoryBot.create(:user)
    @remove_me = FactoryBot.create(:user)
    @group.add_user! @other
    @group.add_user! @remove_me

    @req = RequestToRemoveUser.create! group: @group,
                                       user: @remove_me,
                                       created_by: @other

    assert_difference '@group.users.count', -1 do
      put :update, params: { group_id: @group.to_param, id: @req.id, mark: :approve }
    end
    assert_response :success
  end

  def test_display_request_to_join_you
    login_as users(:penguin)
    get :show, params: { id: requests(:join_animals).id, group_id: :animals }
    assert_response :success
  end

  def test_display_request_to_join_us
    login_as users(:penguin)
    get :show, params: { id: requests(:invite_from_animals).id, group_id: :animals }
    assert_response :success
  end
end
