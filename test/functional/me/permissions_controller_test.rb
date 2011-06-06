require File.dirname(__FILE__) + '/../../test_helper'

class Me::PermissionsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
  end

  def test_not_logged_in
    get :index
    assert_response 302
  end

  def test_default_list
    login_as @user
    get :index
    assert_response :success
    assert_equal 3, assigns(:permissions).count
  end

end
