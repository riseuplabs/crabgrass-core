require 'integration_test'

#
# Tests for the special shortcut urls based on contexts
#
class ContextUrlTest < IntegrationTest

  def test_group_page
    login users(:blue)
    visit '/rainbow/rainbow_page'
    assert_content 'page owned by rainbow'
  end
end
