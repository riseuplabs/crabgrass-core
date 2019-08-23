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
    get :show, params: { group_id: @group.to_param }
    assert_response :success
    assert_select '.inline_message_list', 0
  end

  def test_not_logged_in
    get :show, params: { group_id: @group.to_param }
    assert_login_required
  end

  def test_not_a_member
    stranger = FactoryBot.create(:user)
    login_as stranger
    get :show, params: { group_id: @group.to_param }
    assert_permission_denied
  end

  def test_member_can_see_private
    login_as @user
    @group.revoke_access! public: :all
    get :show, params: { group_id: @group.to_param }
    assert_response :success
    assert_select '.inline_message_list', 0
  end

  def test_update
    login_as @user
    post :update, params: { group: { full_name: 'full name' }, group_id: @group.to_param }
    assert_response 302
    assert_equal 'full name', assigns('group').full_name
  end

  def test_update_not_allowed
    stranger = FactoryBot.create(:user)
    login_as stranger
    post :update, params: { group: { full_name: 'full name' }, group_id: @group.to_param }
    assert_permission_denied
  end

end
