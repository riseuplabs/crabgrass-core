require 'test_helper'
require 'javascript_integration_test'

class TaskOverviewTest < JavascriptIntegrationTest
  fixtures :all

  def test_list_only_pages_with_assigned_tasks
    login users(:blue)
    visit '/me/tasks'
    assert_selector 'h2', text: 'another task list'
    assert_content 'task4'
    assert_no_content 'task6'
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
