require 'test_helper'

class Person::DirectoryControllerTest < ActionController::TestCase
  def test_index
    friends = users(:blue).friends
    login_as :blue
    get :index
    assert_response :success
    users = assigns(:users)

    assert_equal friends.count, users.count
    assert_right_order friends, users
  end

  def test_friends
    login_as :blue
    get :index, params: { path: 'contacts' }
    assert_response :success
    users = assigns(:users)
    assert_equal 2, users.count
    assert_right_order users(:blue).friends, users
  end

  def test_peers
    login_as :blue
    get :index, params: { path: 'peers' }
    assert_response :success
    users = assigns(:users)
    assert_equal 10, users.count
    assert_right_order users(:blue).peers, users
  end

  def test_pagination
    login_as :blue
    def @controller.pagination_params
      { page: 4, per_page: 3 }
    end
    get :index, params: { path: 'peers' }
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
    get :index, params: { query: ' a', path: 'search', format: :json }
    assert_equal [users(:aaron)], assigns(:users)
  end

  private

  def assert_right_order(expected, real, msg = nil)
    assert_equal sorted(expected), real.map(&:login), msg
  end

  def sorted(users)
    users.alphabetic_order.map &:login
  end
end
