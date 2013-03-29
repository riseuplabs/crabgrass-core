require File.dirname(__FILE__) + '/../../test_helper'

class Groups::DirectoryControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create(:user)
  end

  def test_index
    get :index
    assert_response :success

    login_as @user
    get :index
    assert_response :success
  end

end
