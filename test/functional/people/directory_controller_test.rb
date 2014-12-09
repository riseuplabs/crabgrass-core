require File.dirname(__FILE__) + '/../../test_helper'

class People::DirectoryControllerTest < ActionController::TestCase
  fixtures :users, :relationships, :sites, :groups, :memberships

  def test_index
    login_as :blue
    get :index
    assert_response :success
    assert_equal users(:blue).friends.count, assigns(:users).count
  end

  def test_friends
    login_as :blue
    get :index, path: 'contacts'
    assert_response :success
    assert_equal 2, assigns(:users).count
  end

  def test_peers
    login_as :blue
    get :index, path: 'peers'
    assert_response :success
    assert_equal 10, assigns(:users).count
  end

  def test_pagination
    login_as :blue
    def @controller.pagination_params
      {page: 4, per_page: 3}
    end
    get :index, path: 'peers'
    assert_response :success
    ## FIXME: 'count' doesn't work here, because it loses pagination params.
    on_page = users(:blue).peers.count - 9
    on_page = 3 if on_page > 9
    assert_equal on_page, assigns(:users).length
    assert_select '.pagination' do
      # pagination links only up to 3, 4 is current, no next one
      assert_select 'a:last-of-type', '3'
    end
  end

  def test_autocomplete
    login_as :blue
    # leading spaces should be ignored in the query
    get :index, query: ' a', path: 'search', format: :json
    assert_equal [users(:aaron)], assigns(:users)
  end
end

