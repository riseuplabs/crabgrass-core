# TaskListPage

class TaskListPage < Page
  has_many :tasks,
           -> { order 'position' },
           dependent: :destroy,
           foreign_key: :page_id,
           inverse_of: :page

  # Return string of all tasks, for the full text search index
  def body_terms
    tasks.collect { |task| "#{task.name}\t#{task.description}" }.join "\n"
  end

  # Fetch the pages that for the given tasks and include the tasks
  # Now page.tasks will return only the tasks that also were in tasks \o/.
  def self.with_tasks(tasks)
    # For relations we first build the task_ids.
    # Using the relation in the where clause will result in a subselect
    # with a join that makes for a very slow query.
    task_ids = tasks.kind_of?(Array) ? tasks :  tasks.pluck(:id)
    includes(:tasks).where(tasks: { id: task_ids })
  end
end
