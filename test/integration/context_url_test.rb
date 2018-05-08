require 'integration_test'

#
# Tests for the special shortcut urls based on contexts
#
class ContextUrlTest < IntegrationTest
  def test_group_page
    login users(:blue)
    visit '/rainbow/rainbow_page'
    assert_content 'page owned by rainbow'
  end

  def test_group_page_login
    visit '/rainbow/rainbow_page'
    assert_content 'could not find'
    login users(:blue)
    assert_content 'page owned by rainbow'
  end

  def test_new_group_page
    login users(:blue)
    visit '/rainbow/new_rainbow_page'
    assert_content 'This page will be added to group rainbow'
    click_button :create.t
    assert_content 'New rainbow page'
  end

  def test_new_group_page_login
    visit '/rainbow/new_rainbow_page'
    assert_content 'could not find'
    login users(:blue)
    assert_content 'This page will be added to group rainbow'
    click_button :create.t
    assert_content 'New rainbow page'
  end

  def test_other_groups_page
    login users(:penguin)
    visit '/rainbow/new_rainbow_page'
    assert_content 'could not find'
  end
end
