require File.dirname(__FILE__) + '/../../test_helper'

class Groups::HomeControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user!(@user)
  end

  def test_show
    login_as @user
    assert_permission :may_show_groups_home? do
      get :show, :id => @group.to_param
    end
    assert_response :success
  end

  def test_show_public
    @group.grant! :public, :view
    assert_permission :may_show_groups_home? do
      get :show, :id => @group.to_param
    end
    assert_response :success
  end

  def test_may_not_show
    assert_permission :may_show_groups_home?, false do
      get :show, :id => @group.to_param
    end
  end

end
