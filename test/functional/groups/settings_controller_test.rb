require 'test_helper'

class Groups::SettingsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user!(@user)
  end

  def test_not_logged_in
    get :edit, :id => @group.id
    assert_response 302
  end

  def test_logged_in
    login_as @user
    get :edit, :id => @group.id
    assert_response :success
  end

  def test_default_list
    login_as @user
    post :update, :group => {:full_name => 'full name'}, :id => @group.id
    assert_response 302
    assert assigns(:full_name) == 'full name'
  end

end
