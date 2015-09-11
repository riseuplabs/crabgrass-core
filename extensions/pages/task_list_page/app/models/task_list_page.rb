# TaskListPage

class TaskListPage < Page

  has_many :tasks,
    order: "position",
    dependent: :destroy,
    foreign_key: :page_id,
    inverse_of: :page

  # Return string of all tasks, for the full text search index
  def body_terms
    # no need to instantiate all the tasks. Using sql to build the string.
    tasks.pluck('CONCAT(name,"\t",description)').join "\n"
  end

  # Fetch the pages that for the given task_ids and include the tasks
  # Now page.tasks will return only the tasks that were in task_ids \o/.
  def self.with_tasks(task_ids)
    includes(:tasks).where(tasks: {id: task_ids})
  end
end

