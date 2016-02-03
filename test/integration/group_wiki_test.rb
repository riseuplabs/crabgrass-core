require 'javascript_integration_test'

class GroupWikiTest < JavascriptIntegrationTest
  include Capybara::DSL
  include Integration::Wiki

  fixtures :users, :groups, 'group/memberships', :profiles

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

  def test_diff_display
    @user = users(:blue)
    @group = groups(:rainbow)
    @wiki = @group.profiles.public.create_wiki version: 0, body: '', user: @user
    @old = create_wiki_version @user
    membership = @user.memberships.where(group_id: @group).first
    membership.update_column :visited_at, Time.now
    sleep 1
    create_wiki_version users(:red)
    @new = create_wiki_version users(:red)

    login
    visit '/rainbow'
    assert_selector 'article .wiki ins'
    assert_selector 'article .wiki del'
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

  def assert_wiki_content(text)
    assert_selector 'article div.wiki', text: text.gsub("\n", " ")
  end
end
