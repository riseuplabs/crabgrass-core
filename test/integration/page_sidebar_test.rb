require 'javascript_integration_test'

class PageSidebarTest < JavascriptIntegrationTest
  include GroupRecords

  def setup
    super
    own_page
    login
    click_on own_page.title
  end

  def test_sharing_with_user
    share_page_with other_user
    assert_page_users user, other_user
  end

  def test_sharing_with_group
    share_page_with group_to_pester
    assert_page_groups group_to_pester
  end

  def test_tagging
    tags = %w/some tags for this page/
    tag_page tags
    assert_page_tags tags
  end

end
