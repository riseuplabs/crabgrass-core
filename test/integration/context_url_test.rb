require 'integration_test'

#
# Tests for the special shortcut urls based on contexts
#
class ContextUrlTest < IntegrationTest
  def test_accessing_page_with_duplicate_name
    login users(:orange)
    visit 'rainbow/duplicate-name'
    assert_content 'page owned by rainbow'
  end

  def test_accessing_other_page_with_same_name
    login users(:kangaroo)
    visit 'animals/duplicate-name'
    assert_content 'page owned by animals'
  end

  def test_group_page_login
    visit '/rainbow/duplicate-name'
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

  def test_invalid_format
    visit '/rainbow.xml'
    assert_equal 404, status_code
  end

  def test_valid_format
    visit '/rainbow.html'
    assert_equal 200, status_code
  end

  def test_valid_default_format
    visit '/rainbow'
    assert_equal 200, status_code
  end
end
