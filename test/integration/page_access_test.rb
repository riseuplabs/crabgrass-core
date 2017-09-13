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
    assert_not_found
    click_on 'Me'
    assert_content 'Recent Pages'
    assert_no_content page.title
    click_on 'Pages'
    assert_content 'Pages'
    assert_no_content page.title
  end

  def test_public_page_of_hidden_group
    # groups are hidden by default
    page = public_page owner: group
    visit_page(page)
    assert_content page.title
    assert_no_content 'Pages'
  end

  def visit_page(page)
    visit "/pages/#{page.name_url}"
  end
end
