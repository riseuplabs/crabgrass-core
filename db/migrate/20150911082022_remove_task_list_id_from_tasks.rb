class RemoveTaskListIdFromTasks < ActiveRecord::Migration
  def up
    set_page_ids
    clear_data_ids
    remove_index :tasks, name: :index_tasks_task_list_id
    remove_index :tasks, name: :index_tasks_completed_positions
    remove_column :tasks, :task_list_id
  end

  def down
    add_column :tasks, :task_list_id, :integer
    add_index "tasks", ['task_list_id'],
      name: 'index_tasks_task_list_id'
    add_index "tasks", ['task_list_id','completed', 'position'],
      name: 'index_tasks_completed_positions'
  end

  private

  def set_page_ids
    Task.connection.execute <<-EOSQL
      UPDATE tasks JOIN pages ON pages.data_id = tasks.task_list_id
      SET tasks.page_id = pages.id
      WHERE pages.type = 'TaskListPage'
    EOSQL
  end

  def clear_data_ids
    Page.connection.execute <<-EOSQL
      UPDATE pages
      SET data_type = NULL, data_id = NULL
      WHERE data_type = 'TaskList'
    EOSQL
  end
end
