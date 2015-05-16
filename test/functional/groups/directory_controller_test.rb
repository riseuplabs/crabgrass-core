require File.dirname(__FILE__) + '/../../test_helper'

class Groups::DirectoryControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create(:user)
  end

  def test_index_requires_login
    get :index
    assert_response :redirect
    assert_redirected_to '/?redirect=%2Fnetworks%2Fdirectory'
  end

  def test_index
    login_as @user
    get :index
    assert_response :success
  end

end
