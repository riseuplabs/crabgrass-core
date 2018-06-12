require 'javascript_integration_test'

class PageTrashTest < JavascriptIntegrationTest
  fixtures :all

  def setup
    super
    @user = users(:blue)
    own_page
    login
    click_on own_page.title
  end

  def test_destroy_from_trash
    path = current_path
    delete_page
    assert_content 'Notices'
    assert_no_content own_page.title
    assert_equal '/me', current_path
    visit path
    remove_page_from_trash
    assert_content 'Notices'
    assert_no_content own_page.title
    visit path
    assert_content 'Not Found'
  end

end
