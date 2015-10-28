#
# There's a bunch of error scenarios. This test tries to make sure crabgrass
# responds in a meaningful way:
#
# login required -> offer a login form
# permission denied -> display message
# not found -> display not found
# hidden from user -> display not found
#

require 'integration_test'

class ErrorFlowTest < IntegrationTest

  def test_login_required
    visit '/me/pages'
    assert_content 'Login Required'
    assert_equal '/me/pages', current_path
    fill_in 'login', with: 'blue'
    fill_in 'password', with: 'blue'
    click_button :login_button.t
    assert_equal '/me/pages', current_path
  end

  def test_not_found
    visit '/asdfswera'
    assert_content 'Not Found'
    assert_equal '/asdfswera', current_path
    fill_in 'login', with: 'blue'
    fill_in 'password', with: 'blue'
    click_button :login_button.t
    assert_content 'Not Found'
    assert_equal '/asdfswera', current_path
  end

end
