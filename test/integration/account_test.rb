require_relative '../integration_test'

class AccountTest < IntegrationTest

  def test_account_livecycle
    visit '/'
    signup
    logout
    login
    destroy_account
    login
    assert_login_failed
  end

  def test_login_shortcut
    visit '/'
    login
    logout
  end

  def test_password_reset
    @user = FactoryGirl.create(:user)
    request_password_reset
    confirm_password_reset
    login
    logout
  end

  protected

  def request_password_reset
    visit '/account/reset_password'
    fill_in :email, with: @user.email
    click_on 'Reset Password'
    assert_content 'If that email address is associated with a username, then an email has been sent containing instructions for resetting your password.'
    @token = Token.last
  end

  def confirm_password_reset
    visit "/account/reset_password/#{@token}"
    assert_content @user.login
    @user.password = 'password reset'
    fill_in :new_password, with: @user.password
    fill_in :password_confirmation, with: @user.password
    click_on 'Reset Password'
    assert_content 'Your password has been successfully reset.'
  end
end
