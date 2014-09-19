require 'javascript_integration_test'

class PageSideBarTest < JavascriptIntegrationTest

  def setup
    super
    own_page
    login
    click_on own_page.title
  end

  def test_tagging
    tags = %w/some tags for this page/
    tag_page tags
    assert_page_tags tags
  end

end
