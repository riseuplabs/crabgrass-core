# TaskListPage

class TaskListPage < Page

  # has_many :tasks

  # Return string of all tasks, for the full text search index
  def body_terms
    data.tasks.pluck('CONCAT(name,"\t",description)').join "\n"
  end
end

