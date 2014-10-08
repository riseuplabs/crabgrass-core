require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  fixtures :pages, :users, :task_lists, :tasks

  def test_sort
    login_as :blue

    @user = users(:blue)
    @page = pages(:tasklist1)
    @page.add(@user, access: :admin)
    @page.save!

    assert_equal 1, Task.find(1).position
    assert_equal 2, Task.find(2).position
    assert_equal 3, Task.find(3).position

    xhr :post, :sort, page_id: @page.id, sort_list_pending: ["3","2","1"]
    assert_response :success

    assert_equal 3, Task.find(1).position
    assert_equal 2, Task.find(2).position
    assert_equal 1, Task.find(3).position
  end

  def test_create_task
    login_as :blue
    pages(:tasklist1).add(users(:blue), access: :admin)
    pages(:tasklist1).save!
    assert_difference 'pages(:tasklist1).data.tasks.count' do
      xhr :post, :create, page_id: pages(:tasklist1).id, task: {name: "new task", user_ids: ["5"], description: "new task description"}
    end
  end
end
