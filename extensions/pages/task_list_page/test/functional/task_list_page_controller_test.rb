require 'test_helper'

class TaskListPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :tasks

  def test_show
    login_as :quentin

    get :show, id: pages(:tasklist1)
    assert_response :success
  end

end
