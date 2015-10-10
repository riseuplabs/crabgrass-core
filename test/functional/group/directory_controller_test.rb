require 'test_helper'

class Group::DirectoryControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create(:user)
  end

  def test_index_requires_login
    assert_login_required do
      get :index
    end
  end

  def test_index
    login_as @user
    get :index
    assert_response :success
  end

end
