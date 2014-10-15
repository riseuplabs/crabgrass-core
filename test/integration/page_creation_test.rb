require 'javascript_integration_test'

class PageCreationTest < JavascriptIntegrationTest
  include GroupRecords

  def test_sharing_with_users
    login
    create_page :discussion_page,
      share_with: [other_user, hidden_user, blocking_user]
    assert_no_content hidden_user.display_name
    assert_no_content blocking_user.display_name
    assert_page_users user, other_user
  end

  def test_sharing_with_groups
    login
    create_page :discussion_page,
      share_with: [group, hidden_group, group_to_pester]
    assert_no_content hidden_group.display_name
    assert_no_content group.display_name
    assert_page_users user
    assert_page_groups group_to_pester
  end

  def assert_page_users(*users)
    assert_equal users.map(&:display_name).join(' '),
      find('#people.names').text
  end

  def assert_page_groups(*groups)
    assert_equal groups.map(&:display_name).join(' '),
      find('#groups.names').text
  end
end
