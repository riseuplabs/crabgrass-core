require 'test_helper'
require 'javascript_integration_test'

class TaskOverviewTest < JavascriptIntegrationTest

  fixtures :users, :pages, 'page/terms', :tasks, 'task/participations'

  def test_list_only_pages_with_assigned_tasks
    login users(:blue)
    visit '/me/tasks'
    assert_selector 'h2', text: 'another task list'
    # the only pending task assigned to me
    assert_content 'task5'
    assert_no_content 'task4' # not pending
    assert_no_content 'task6' # not assigned to me
    assert_no_selector 'h2', text: 'a task list'
    assert_no_content 'task1'
  end

  def test_no_deleted_pages
    pages(:tasklist2).delete
    login users(:blue)
    visit '/me/tasks'
    assert_no_selector 'h2', text: 'another task list'
    assert_no_content 'task4'
  end



end
