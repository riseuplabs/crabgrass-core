require 'test_helper'

class Person::HomeControllerTest < ActionController::TestCase
  def test_show
    login_as :blue
    get :show, params: { person_id: 'blue' }
    assert_response :success
  end

  def test_show_hidden_self
    login_as :blue
    blue = users(:blue)
    blue.revoke_access! friends: :view
    blue.revoke_access! peers: :view
    blue.revoke_access! public: :view
    get :show, params: { person_id: 'blue' }
    assert_response :success
  end

  def test_new_user_hidden
    user = FactoryBot.create :user
    login_as :blue
    assert !users(:blue).may?(:view, user)
    assert users(:blue).may?(:pester, user)
    assert users(:blue).may?(:request_contact, user) # TODO: this is not a controller test. Either replace by integration test or find another way of testing it in the controller.
  end

  def test_missing_user
    login_as :blue
    get :show, params: { person_id: 'missinguserlogin' }
    assert_not_found
  end

  def test_new_user_visible_to_friends
    user = FactoryBot.create :user
    user.add_contact! users(:blue), :friend
    login_as :blue
    get :show, params: { person_id: user.login }
    assert_response :success
    assert_equal user, assigns[:user]
  end
end
