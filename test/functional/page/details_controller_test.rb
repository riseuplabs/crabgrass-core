require 'test_helper'

class Page::DetailsControllerTest < ActionController::TestCase
  def test_show_details
    page = pages(:blue_page)
    login_as users(:blue)
    xhr :get, :show, page_id: page.id
    assert_response :success
  end

  def test_show_details_not_allowed
    page = pages(:blue_page)
    login_as users(:penguin)
    assert_permission_denied do
      xhr :get, :show, page_id: page.id
    end
  end
end
