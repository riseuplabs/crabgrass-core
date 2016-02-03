require 'javascript_integration_test'

class CollaborationTest < JavascriptIntegrationTest
  include Integration::Wiki
  include Integration::Navigation



  def setup
    super
    @user = users(:blue)
    @page = new_page :wiki_page, owner: groups(:rainbow), created_by: @user
    @page.data = @wiki = Wiki.create(user: @user, body: "")
    @old = create_wiki_version @user
    @page.add @user, viewed_at: Time.now
    sleep 1
    create_wiki_version users(:red)
    @new = create_wiki_version users(:red)
    save_and_index(@page)
  end

  def test_diff_since_last_visit
    login
    click_on @page.title
    assert_selector 'ins', text: @new
    assert_selector 'del', text: @old
  end

  protected

  def assert_wiki_content(text)
    assert_selector 'article div.wiki', text: text.gsub("\n", " ")
  end
end


