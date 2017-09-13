require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  def setup
    @user = users(:blue)
    @page = pages(:tasklist1)
    @page.add(@user, access: :admin)
    @page.save!
    login_as @user
  end

  def test_sort
    assert_equal 1, Task.find(1).position
    assert_equal 2, Task.find(2).position
    assert_equal 3, Task.find(3).position

    xhr :post, :sort, page_id: @page.id, sort_list_pending: %w[3 2 1]
    assert_response :success

    assert_equal 3, Task.find(1).position
    assert_equal 2, Task.find(2).position
    assert_equal 1, Task.find(3).position
  end

  def test_create_task
    assert_difference '@page.tasks.count' do
      xhr :post, :create, page_id: @page.id,
                          task: { name: 'new task', user_ids: ['5'], description: 'new task description' }
    end
  end

  def test_update_task
    task = @page.tasks.create name: 'blue... do something!',
                              user_ids: [@user.id]
    assert_difference '@user.tasks.count', -1 do
      xhr :put, :update, page_id: @page, id: task.id,
                         task: { name: 'updated task', description: 'new task description' }
    end
  end
end
