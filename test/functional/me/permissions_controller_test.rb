require 'test_helper'

class Me::PermissionsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
  end

  def test_not_logged_in
    get :index
    assert_login_required
  end

  def test_default_list
    login_as @user
    get :index
    assert_response :success
    assert_equal 3, assigns(:holders).count
  end
end
