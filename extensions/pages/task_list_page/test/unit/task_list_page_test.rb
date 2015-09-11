require 'test_helper'

class TaskListPageTest < ActiveSupport::TestCase
  fixtures :tasks, :pages

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

  def expected_body_terms
    expected_body_terms = [1,2,3]
      .map {|n| "task#{n}\ttask#{n} description"}
      .join "\n"
  end
end
