require 'javascript_integration_test'

class PageSidebarTest < JavascriptIntegrationTest
  include GroupRecords

  def setup
    super
    @user = users(:blue)
    own_page
    login
    click_on own_page.title
  end

  def test_sharing_with_user
    share_page_with users(:red)
    assert_page_users user, users(:red)
  end

  def test_sharing_with_group
    share_page_with groups(:animals)
    assert_page_groups groups(:animals)
  end

  def test_tagging
    tags = %w/some tags for this page/
    tag_page tags
    assert_page_tags tags
  end

  def test_trash
    path = current_path
    delete_page
    assert_no_content own_page.title
    assert_equal '/me', current_path
    visit path
    undelete_page
    assert_content 'Delete Page'
    click_on 'Dashboard'
    assert_content own_page.title
  end

end
