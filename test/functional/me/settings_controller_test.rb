require File.dirname(__FILE__) + '/../../test_helper'

class Me::SettingsControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
  end

  def test_not_logged_in
    get :show
    assert_login_required
  end

  def test_show
    login_as @user
    get :show
    assert_response :success
  end

  def test_update
    login_as @user
    post :update, user: {login: 'new_login'}
    assert_equal 'new_login', @user.reload.login, "login should have changed"
  end

  def test_password_fail
    login_as @user
    post :update, user: {password: 'sdofi33si', password_confirmation: 'xxxxxxx'}
    assert_error_message /password doesn.t match confirmation/i
  end

end
