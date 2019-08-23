require 'test_helper'

class TaskListPageControllerTest < ActionController::TestCase
  def test_show
    login_as :quentin

    get :show, params: {id: pages(:tasklist1)}
    assert_response :success
  end
end
