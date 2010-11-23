require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
  end

  def test_not_logged_in
    get :index
    assert_response 404
  end

  def test_empty_list
    login_as @user
    get :index
    assert_response :success
    assert_equal [], assigns(:permissions)
  end

  def test_list_with_friends
    @user.allow! [:view, :pester], @user.friends
    login_as @user
    get :index
    assert_response :success
    assert_equal 1, assigns(:permissions).count
  end

end
