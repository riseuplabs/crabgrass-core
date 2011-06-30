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

  def test_pagination
    login_as :blue
    def @controller.pagination_params
      {:page => 4, :per_page => 4}
    end
    get :index
    assert_response :success
    # 13 users total - so 1 on the fourth page
    assert_equal 1, assigns(:users).count
    assert_select '.pagination' do
      # pagination links only up to 3, 4 is current, no next one
      assert_select 'a:last-of-type', '3'
    end
  end
end

