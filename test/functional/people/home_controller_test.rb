require File.dirname(__FILE__) + '/../../test_helper'

class People::HomeControllerTest < ActionController::TestCase
  fixtures :users, :relationships, :sites, :groups, :memberships

  def test_show
    login_as :blue
    get :show, :person_id => 'blue'
    assert_response :success
  end

  def test_new_user_hidden
    user = FactoryGirl.create :user
    login_as :blue
    get :show, :person_id => user.login
    assert_no_user_found
    user.destroy
  end

  def test_missing_user
    login_as :blue
    get :show, :person_id => "missinguserlogin"
    assert_no_user_found
  end

  def test_new_user_visible_to_friends
    user = FactoryGirl.create :user
    user.add_contact! users(:blue), :friend
    login_as :blue
    get :show, :person_id => user.login
    assert_response :success
    assert_equal user, assigns[:user]
    user.destroy
  end

  # there should be no difference between a hidden user
  # and a user not found...
  def assert_no_user_found
    assert_response 404
    assert_nil assigns[:user]
    assert_nil assigns[:group]
  end
end
