require File.dirname(__FILE__) + '/../../test_helper'

class People::DirectoryControllerTest < ActionController::TestCase
  fixtures :users, :relationships, :sites, :groups, :memberships

  def test_index
    login_as :blue
    get :index
    assert_response :success
    assert_equal 13, assigns(:users).count
  end

  def test_friends
    login_as :blue
    get :index, :path => 'friends'
    assert_response :success
    assert_equal 2, assigns(:users).count
  end

  def test_peers
    login_as :blue
    get :index, :path => 'peers'
    assert_response :success
    assert_equal 10, assigns(:users).count
  end

end

