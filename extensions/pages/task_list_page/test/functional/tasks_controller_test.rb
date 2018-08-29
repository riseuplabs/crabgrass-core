require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  def setup
    @user = users(:blue)
    @page = pages(:tasklist1)
    @page.add(@user, access: :admin)
    @page.save!
    login_as @user
  end

  def test_create_task
    assert_difference '@page.tasks.count' do
      post :create, params: { page_id: @page.id, task: { name: "new task", user_ids: ["5"], description: "new task description" } }, xhr: true
    end
  end

  def test_update_task
    task = @page.tasks.create name: 'blue... do something!',
                              user_ids: [@user.id]
    assert_difference '@user.tasks.count', -1 do
      put :update, params: { page_id: @page, id: task.id, task: { name: "updated task", description: "new task description" } }, xhr: true
    end
  end
end
