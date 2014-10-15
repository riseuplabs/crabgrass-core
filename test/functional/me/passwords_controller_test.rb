require 'test_helper'

class Me::PasswordsControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
  end

  def test_not_logged_in
    get :edit
    assert_login_required
  end

  def test_edit
    login_as @user
    get :edit
    assert_response :success
  end

  def test_update
    login_as @user
    post :update, user: {password: 'sdofi33si', password_confirmation: 'sdofi33si'}
    @user.reload
    hashed = @user.encrypt('sdofi33si')
    assert_equal hashed, @user.crypted_password,
      "password should have been updated."
  end

  def test_password_fail
    login_as @user
    post :update, user: {password: 'sdofi33si', password_confirmation: 'xxxxxxx'}
    assert_error_message /password doesn.t match confirmation/i
  end

end
