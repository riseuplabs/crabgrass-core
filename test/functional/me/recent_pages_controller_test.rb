require 'test_helper'

class Me::RecentPagesControllerTest < ActionController::TestCase



  def test_index
    login_as users(:blue)
    xhr :get, :index
    assert_response :success
  end

end
