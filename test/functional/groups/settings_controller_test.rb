require File.dirname(__FILE__) + '/../../test_helper'

class Groups::SettingsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user!(@user)
  end

  def test_not_logged_in
    get :show, :id => @group.to_param
    assert_response 302
  end

  def test_logged_in
    login_as @user
    get :show, :id => @group.to_param
    assert_response :success
  end

  def test_update
    login_as @user
    post :update, :group => {:full_name => 'full name'}, :id => @group.to_param
    assert_response 302
    assert_equal 'full name', assigns('group').full_name
  end

end
