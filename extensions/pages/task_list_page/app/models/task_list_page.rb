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
end

