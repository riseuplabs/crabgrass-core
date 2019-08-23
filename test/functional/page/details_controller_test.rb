require 'test_helper'

class Page::DetailsControllerTest < ActionController::TestCase
  def test_show_details
    page = pages(:blue_page)
    login_as users(:blue)
    get :show, params: { page_id: page.id }, xhr: true
    assert_response :success
  end

  def test_show_details_not_allowed
    page = pages(:blue_page)
    login_as users(:penguin)
    get :show, params: { page_id: page.id }, xhr: true
    assert_permission_denied
  end
end
