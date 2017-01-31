require 'test_helper'

class RootControllerTest < ActionController::TestCase


  def test_show
    get :index
    assert_response :success
  end

  def test_redirect_if_logged_in
    login_as users(:blue)
    get :index
    assert_response :redirect
    assert_redirected_to me_home_path
  end
end
