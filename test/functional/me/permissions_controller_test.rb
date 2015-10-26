require File.dirname(__FILE__) + '/../../test_helper'

class Me::PermissionsControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
  end

  def test_not_logged_in
    assert_login_required do
      get :index
    end
  end

  def test_default_list
    login_as @user
    get :index
    assert_response :success
    assert_equal 3, assigns(:holders).count
  end

end
