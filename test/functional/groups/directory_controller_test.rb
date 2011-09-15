require File.dirname(__FILE__) + '/../../test_helper'

class Groups::DirectoryControllerTest < ActionController::TestCase

  def setup
    @user = User.make
  end

  def test_index
    get :index
    assert_response :success

    login_as @user
    get :index
    assert_response :success
  end

end
