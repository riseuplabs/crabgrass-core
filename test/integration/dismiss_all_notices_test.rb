require 'javascript_integration_test'

class DismissAllNoticesTest < JavascriptIntegrationTest
  def test_dismiss_all_notices_updates_page
    login users(:blue)
    msg = 'hey, check out this page'

    visit '/me'
    assert_selector('.dismiss-all-notices-btn', visible: true)
    assert_content msg

    click_on :dismiss_all_notices.t
    click_on :ok_button.t

    assert_no_selector('.dismiss-all-notices-btn', visible: true)
    assert_no_content msg
  end
end
