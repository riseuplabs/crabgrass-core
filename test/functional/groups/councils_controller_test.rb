require File.dirname(__FILE__) + '/../../test_helper'

class Groups::CouncilsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user! @user
  end


  def test_new
    login_as @user
    assert_permission :may_create_groups_council? do
      get :new, :group_id => @group.to_param
    end
    assert_response :success
  end

  def test_create
    login_as @user
    assert_permission :may_create_groups_council? do
      assert_difference '@group.committees.count' do
        get :create, :group_id => @group.to_param,
         :council => Council.plan
      end
    end
    assert_response :redirect
  end
end
