require 'test_helper'

class Group::SettingsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.grant_access! public: :view
    @group.add_user!(@user)
  end

  def test_logged_in
    login_as @user
    assert_permission :may_admin_group? do
      get :show, group_id: @group.to_param
    end
    assert_response :success
    assert_select '.inline_message_list', 0
  end

  def test_not_logged_in
    assert_login_required do
      get :show, group_id: @group.to_param
    end
  end

  def test_not_a_member
    stranger = FactoryBot.create(:user)
    login_as stranger
    assert_permission :may_admin_group?, false do
      assert_permission_denied do
        get :show, group_id: @group.to_param
      end
    end
  end

  def test_member_can_see_private
    login_as @user
    @group.revoke_access! public: :all
    get :show, group_id: @group.to_param
    assert_response :success
    assert_select '.inline_message_list', 0
  end

  def test_update
    login_as @user
    assert_permission :may_admin_group? do
      post :update, group: { full_name: 'full name' }, group_id: @group.to_param
    end
    assert_response 302
    assert_equal 'full name', assigns('group').full_name
  end
end
