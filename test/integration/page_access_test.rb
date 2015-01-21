require 'javascript_integration_test'

class PageAccessTest < JavascriptIntegrationTest

  def test_loosing_access
    page = public_page
    login
    visit_page(page)
    assert page.public?
    assert_content page.title
    watch_page
    assert_page_watched
    page.public = false
    page.save
    visit_page(page)
    assert_content 'Not Found'
  end

  def visit_page(page)
    visit "/pages/#{page.name_url}"
  end
end
