require 'test_helper'

class Group::ProfilesControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user! @user
  end

  def test_edit
    login_as @user
    get :edit, group_id: @group.to_param
    assert_response :success
  end

  def test_edit_not_allowed
    stranger = FactoryBot.create(:user)
    login_as stranger
    assert_not_found do
      get :edit, group_id: @group.to_param
    end
  end

  def test_update
    login_as @user
    post :update, group_id: @group.to_param,
                  profile: { summary: 'test profile', entity_id: 1 }
    assert_response :redirect
    profile = @group.profiles.public.reload
    assert_equal 'test profile', profile.summary
    assert_equal @group, profile.entity
  end

  def test_update
    stranger = FactoryBot.create(:user)
    login_as stranger
    assert_not_found do
      post :update, group_id: @group.to_param,
                    profile: { summary: 'test profile', entity_id: 1 }
    end
  end

end
