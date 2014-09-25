require 'javascript_integration_test'

class RateManyPageTest < JavascriptIntegrationTest

  def setup
    super
    own_page :rate_many_page
    login
    click_on own_page.title
  end

  def test_loading
    assert_page_header
  end

end
