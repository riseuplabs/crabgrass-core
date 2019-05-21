require 'test_helper'

class Group::DirectoryControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
  end

  def test_index_requires_login
    get :index
    assert_login_required
  end

  def test_index
    login_as @user
    get :index
    assert_response :success
  end
end
