require 'test_helper'

class Group::ProfilesControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group)
    @group.add_user! @user
  end

  def test_edit
    login_as @user
    assert_permission :may_admin_group? do
      get :edit, group_id: @group.to_param
    end
    assert_response :success
  end

  def test_update
    login_as @user
    assert_permission :may_admin_group? do
      post :update, group_id: @group.to_param,
                    profile: { summary: 'test profile', entity_id: 1 }
    end
    assert_response :redirect
    profile = @group.profiles.public.reload
    assert_equal 'test profile', profile.summary
    assert_equal @group, profile.entity
  end
end
