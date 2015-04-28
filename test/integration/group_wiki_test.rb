require 'javascript_integration_test'

class GroupWikiTest < JavascriptIntegrationTest
  include Capybara::DSL

  # let's not wait for wiki lock requests.
  # They are triggered automatically when leaving the settings window
  # Since they run after the page was left their response will not
  # show up in network_traffic
  # TODO: make sure we only clear locks that still were used.
  def pending_ajax
    super.reject do |req|
      req.url.include?('lock')
    end
  end

  def test_initial_wiki_creation
    login users(:blue)
    visit '/groups/rainbow/wikis'
    create_group_wiki :public
    edit_group_wiki :public
    fill_in "wiki[body]", with: "h2. test content\n\n"
    click_on 'Save'
    assert_content 'Changes saved'
    assert_selector '.wiki h2', text: 'test content'
    click_on 'Home'
    assert_selector '.wiki h2', text: 'test content'
  end

  protected

  def create_group_wiki(type)
    find("##{type}_link").click
    click_on 'Create Group Wiki'
  end

  def edit_group_wiki(type)
    find("##{type}_link").click
    click_on 'Edit'
  end

end
