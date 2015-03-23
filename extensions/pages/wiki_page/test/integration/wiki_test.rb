require 'javascript_integration_test'

class WikiTest < JavascriptIntegrationTest
  include Integration::Wiki
  include Integration::Navigation

  def setup
    super
    own_page :wiki_page
    login
    click_on own_page.title
  end

  def test_writing_initial_version
    assert_page_tab "Edit"
    content = update_wiki
    assert_content content
    assert_page_tab "Show"
    assert_success "Changes saved"
  end

  def test_format_help
    find('.edit_wiki').click_on 'Editing Help'
    help = windows.last
    within_window help do
      assert_content 'GreenCloth'
    end
  end

  def test_versioning
    versions = []
    3.times do
      versions << update_wiki
      assert_content versions.last
    end
    click_page_tab "Versions"
    assert_wiki_unlocked
    assert_no_content "Version 4"
    find("span.b", text: "3", exact: false).click
    clicking "previous" do
      assert_content versions.pop
    end
  end

  def assert_wiki_unlocked
    request_urls = page.driver.network_traffic.map(&:url)
    assert request_urls.detect{|u| u.end_with? '/lock'}.present?
    # the unlock request is triggered from onbeforeunload.
    # So the response will never be registered by the page.
    # In order to prevent the check for pending ajax from failing...
    page.driver.clear_network_traffic
  end
end
