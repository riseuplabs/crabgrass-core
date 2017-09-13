require 'test_helper'

class Person::HomeControllerTest < ActionController::TestCase
  def test_show
    login_as :blue
    get :show, person_id: 'blue'
    assert_response :success
  end

  def test_show_hidden_self
    login_as :blue
    blue = users(:blue)
    blue.revoke_access! friends: :view
    blue.revoke_access! peers: :view
    blue.revoke_access! public: :view
    get :show, person_id: 'blue'
    assert_response :success
  end

  def test_new_user_hidden
    user = FactoryGirl.create :user
    login_as :blue
    assert_not_found do
      get :show, person_id: user.login
    end
  end

  def test_missing_user
    login_as :blue
    assert_not_found do
      get :show, person_id: 'missinguserlogin'
    end
  end

  def test_new_user_visible_to_friends
    user = FactoryGirl.create :user
    user.add_contact! users(:blue), :friend
    login_as :blue
    get :show, person_id: user.login
    assert_response :success
    assert_equal user, assigns[:user]
  end
end
