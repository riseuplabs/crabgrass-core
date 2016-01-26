require 'test_helper'

class Me::PasswordsControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
  end

  def test_not_logged_in
    assert_login_required do
      get :edit
    end
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
    assert @user.authenticate('sdofi33si')
  end

  def test_password_fail
    login_as @user
    post :update, user: {password: 'sdofi33si', password_confirmation: 'xxxxxxx'}
    assert_error_message /doesn.t match/i
  end

end
