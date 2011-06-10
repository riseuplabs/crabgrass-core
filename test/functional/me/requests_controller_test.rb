require File.dirname(__FILE__) + '/../../test_helper'

class Me::RequestsControllerTest < ActionController::TestCase

  fixtures :users, :requests

  def test_destroy
    login_as users(:blue)
    request = Request.created_by(users(:blue)).find(:first)
    xhr :delete, :destroy, :id => request.id
    assert_message /destroyed/i
  end

end
