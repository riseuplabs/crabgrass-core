require 'test_helper'

class Group::PermissionsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @other_user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user!(@user)
  end

  def test_index
    login_as @user
    get :index, params: { group_id: @group.to_param }
    assert_response :success
  end

  def test_index_with_council
    login_as users(:blue)
    get :index, params: { group_id: groups(:groupwithcouncil) }
    assert_response :success
  end

  def test_index_no_access
    login_as @other_user
    get :index, params: { group_id: @group.to_param }
    assert_not_found
  end

  def test_update
    public_code = @controller.send(:key_holders, :public).first.code
    login_as @user
    post :update, params: { group_id: @group.to_param, id: public_code, gate: "view", new_state: "open" }, xhr: true
    assert_response :success
    assert @group.has_access?(:view, :public)
  end
end
