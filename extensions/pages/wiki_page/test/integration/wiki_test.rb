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
    # assert_page_tab "Edit"
    content = update_wiki
    assert_content content
    assert_page_tab "Show"
    assert_success "Changes saved"
  end

  def test_versioning
    versions = []
    3.times do
      versions << update_wiki
      assert_content versions.last
    end
    click_page_tab "Versions"
    assert_no_content "Version 4"
    find("span.b", :text => "3", :exact => false).click
    clicking "previous" do
      assert_content versions.pop
    end
  end

end
