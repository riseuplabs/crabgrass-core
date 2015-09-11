class DropTaskLists < ActiveRecord::Migration
  def up
    drop_table :task_lists
  end

  def down
    create_table :task_lists
  end
end
