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
  ensure
    cleanup_user
  end

  def test_login_shortcut
    visit '/'
    login
    logout
  ensure
    cleanup_user
  end
end
