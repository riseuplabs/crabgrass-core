require 'test_helper'

class TaskListPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :task_lists, :tasks

  def test_show
    login_as :quentin

    get :show, id: pages(:tasklist1)
    assert_response :success
#    assert_template 'task_list_page/show'
  end

  # TODO: still missing a bunch of functional tests

end
