require 'javascript_integration_test'

class PageSearchTest < JavascriptIntegrationTest
  include Integration::Search

  def test_initial_search
    # new page so it shows up on top
    login users(:blue)
    own_page
    click_on 'Pages'
    assert_content own_page.title
  end

  def test_owned_by_me
    login users(:blue)
    own_page
    click_on 'Pages'
    click_on 'Own'
    assert_content 'Owned By Me'
    assert_text_of_all 'td.owner', user.login
    assert_content own_page.title
  end

  def test_deleted
    login users(:blue)
    own_page(flow: FLOW[:deleted])
    click_on 'Pages'
    assert_content 'Owner'
    assert_no_content own_page.title
    click_on 'Deleted'
    assert_content own_page.title
  end

  def assert_text_of_all(selector, text)
    all(selector).each do |elem|
      assert_equal text, elem.text
    end
  end
end
