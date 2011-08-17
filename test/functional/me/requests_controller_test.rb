require File.dirname(__FILE__) + '/../../test_helper'

class Me::RequestsControllerTest < ActionController::TestCase

  fixtures :users, :requests

  def test_destroy
    login_as users(:blue)
    request = Request.created_by(users(:blue)).find(:first)
    assert_permission :may_destroy_request? do
      xhr :delete, :destroy, :id => request.id
    end
    assert_message /destroyed/i
  end

  def test_index
    login_as users(:blue)
    get :index
    assert_response :success
  end

end
