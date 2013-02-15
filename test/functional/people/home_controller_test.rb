require File.dirname(__FILE__) + '/../../test_helper'

class People::HomeControllerTest < ActionController::TestCase
  fixtures :users, :relationships, :sites, :groups, :memberships

  def test_show
    login_as :blue
    get :show, :person_id => 'blue'
    assert_response :success
  end
end
