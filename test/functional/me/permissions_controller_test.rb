require File.dirname(__FILE__) + '/../../test_helper'

class Me::PermissionsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
  end

  def test_not_logged_in
    get :index
    assert_login_required
  end

  def test_default_list
    login_as @user
    get :index
    assert_response :success
    assert_equal 5, assigns(:locks).count
  end

end
