require 'javascript_integration_test'

class WikiIntegrationTest < JavascriptIntegrationTest
  include Integration::Wiki
  include Integration::Navigation

  fixtures :users

  def setup
    super
    own_page :wiki_page
  end

  def test_writing_initial_version
    visit_page
    assert_page_tab 'Edit'
    content = update_wiki
    assert_content content
    assert_page_tab 'Show'
    assert_success 'Changes saved'
  end

  def test_cancel_edit
    visit_page
    assert_page_tab 'Edit'
    click_button 'Cancel'
    assert_page_tab 'Show'
  end

  def test_format_help
    visit_page
    find('.edit_wiki').click_on 'Editing Help'
    help = windows.last
    within_window help do
      assert_content 'GreenCloth'
    end
  end

  def test_versioning_with_diff
    seed_version
    visit_page
    versions = []
    3.times do
      versions << update_wiki
      assert_content versions.last
    end
    click_page_tab 'Versions'
    assert_wiki_unlocked
    assert_no_content 'Version 3'
    find('span.b', text: '2').click
    clicking 'previous' do
      assert_selector 'ins', text: versions.pop
      assert_selector 'del', text: versions.last if versions.last.present?
    end
  end

  def test_wiki_toc
    visit_page
    content = update_wiki <<-EOWIKI.strip_heredoc
      [[toc]]

      h1. test table of content

      h2. with nested section

      and some content
    EOWIKI
    assert_content 'table of content'
    assert_selector 'li.toc1'
  end

  def test_section_editing
    visit_page
    content = update_wiki <<-EOWIKI.strip_heredoc
      h2. section to keep

      kept content

      h2. section to edit

      with content
    EOWIKI
    update_section 'section to edit', <<-EOSEC.strip_heredoc
      h2. edited section

      with content
    EOSEC
    assert_selector 'h2', text: 'edited section'
    assert_no_selector 'h2', text: 'section to edit'
    assert_selector 'h2', text: 'section to keep'
  end

  def visit_page
    login
    click_on own_page.title
  end

  # let's have some other users content so we can create a new version
  def seed_version
    own_page.data.update_section!(:document, users(:blue), nil, 'bla')
    own_page.save
  end

  def assert_wiki_unlocked
    request_urls = page.driver.network_traffic.map(&:url)
    assert request_urls.detect { |u| u.end_with? '/lock' }.present?
    # the unlock request is triggered from onbeforeunload.
    # So the response will never be registered by the page.
    # In order to prevent the check for pending ajax from failing...
    page.driver.clear_network_traffic
  end
end
