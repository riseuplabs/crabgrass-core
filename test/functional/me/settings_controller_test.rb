require 'test_helper'

class Me::SettingsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create :user
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
    post :update, params: { user: {
      login: 'new_login',
      password: 'xxxxxxxx',
      password_confirmation: 'xxxxxxx'
    } }
    assert_equal @user.password_digest, @user.reload.password_digest,
                 "password can't be changed in settings"
    assert_equal 'new_login', @user.login, 'login should have changed'
  end

  def test_password_fail
    login_as @user
    post :update, params: { user: { password: 'xxxxxxxx', password_confirmation: 'xxxxxxx' } }
  end
end
