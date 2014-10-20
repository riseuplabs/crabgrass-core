require 'javascript_integration_test'

class PageSearchTest < JavascriptIntegrationTest
  fixtures :users

  def test_initial_search
    # new page so it shows up on top
    own_page
    login users(:blue)
    click_on 'Pages'
    assert_content own_page.title
  end

end
