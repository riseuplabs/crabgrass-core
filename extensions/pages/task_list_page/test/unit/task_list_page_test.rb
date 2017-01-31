require 'test_helper'

class TaskListPageTest < ActiveSupport::TestCase


  def test_body_terms
    page = pages(:tasklist1)
    assert_equal expected_body_terms, page.body_terms
  end

  def test_deletion
    page = pages(:tasklist1)
    id = page.tasks.first.id
    page.destroy
    assert_nil Task.find_by_id(id), 'deleting the page should delete the tasks'
  end

  def test_with_tasks_fetches_right_pages
    assert_equal 1, TaskListPage.with_tasks([1,2]).count
    assert_equal 2, TaskListPage.with_tasks([1,4]).count
  end

  def test_with_tasks_includes_right_tasks
    pages = TaskListPage.with_tasks([1,2,5,6])
    assert_equal [tasks(:task1), tasks(:task2)], pages.first.tasks
  end

  def expected_body_terms
    expected_body_terms = [1,2,3]
      .map {|n| "task#{n}\ttask#{n} description"}
      .join "\n"
  end
end
