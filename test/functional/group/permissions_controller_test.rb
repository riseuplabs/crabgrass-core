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
    get :index, group_id: @group.to_param
    assert_response :success
  end

  def test_index_no_access
    login_as @other_user
    assert_not_found do
      get :index, group_id: @group.to_param
    end
  end

  def test_update
    public_code = @controller.send(:key_holders, :public).first.code
    login_as @user
    xhr :post, :update,
        group_id: @group.to_param,
        id: public_code,
        gate: 'view',
        new_state: 'open'
    assert_response :success
    assert @group.has_access?(:view, :public)
  end
end
