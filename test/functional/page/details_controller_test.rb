require 'test_helper'

class Page::DetailsControllerTest < ActionController::TestCase
  def test_show_details
    user = users(:blue)
    page = user.pages.last
    login_as user
    xhr :get, :show, page_id: page.id
    assert_response :success
  end
end
