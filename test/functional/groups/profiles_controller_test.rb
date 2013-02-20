require File.dirname(__FILE__) + '/../../test_helper'

class Groups::ProfilesControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
    @group  = FactoryGirl.create(:group)
    @group.add_user! @user
  end

  def test_edit
    login_as @user
    assert_permission :may_admin_group? do
      get :edit, :group_id => @group.to_param
    end
    assert_response :success
  end

  def test_update
    login_as @user
    assert_permission :may_admin_group? do
      post :update, :group_id => @group.to_param,
        :profile => {}
    end
    assert_response :redirect
  end

end
