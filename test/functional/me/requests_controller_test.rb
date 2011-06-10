require File.dirname(__FILE__) + '/../../test_helper'

class Me::RequestsControllerTest < ActionController::TestCase

  fixtures :users, :requests

  def test_destroy
    flunk 'not yet done as templates are in weird spot. also regexp should be fixed'
    login_as users(:blue)
    request = Request.created_by(users(:blue)).find(:first)
    xhr :delete, :destroy, :id => request.id
    assert_message /skdjhsf/i
  end

end
