require 'javascript_integration_test'

class PageCreationTest < JavascriptIntegrationTest
  include GroupRecords

  def test_sharing_with_users
    login
    prepare_page :discussion_page
    add_recipients public_user, autocomplete: true
    # hidden users do not show up in autocomplete
    add_recipients hidden_user, blocking_user
    click_on :create.t

    assert_content public_user.display_name
    assert_no_content blocking_user.display_name
    assert_page_users user, public_user, hidden_user
  end

  def test_setting_owner
    login users(:red)
    prepare_page :discussion_page
    select 'rainbow', from: :page_owner
    click_on :create.t
    find('#banner_content').assert_text 'rainbow'
  end

  def test_sharing_with_groups
    login
    prepare_page :discussion_page
    add_recipients public_group, public_group_to_pester, autocomplete: true
    add_recipients group_to_pester
    add_recipients group
    click_on :create.t
    assert_page_groups group_to_pester, public_group_to_pester
    # can't share with group by default
    assert_no_content group.display_name
    # can't share with public_group by default
    assert_no_content public_group.display_name
    assert_page_users user
  end
end
