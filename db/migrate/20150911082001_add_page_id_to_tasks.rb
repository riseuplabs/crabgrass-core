class AddPageIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :page_id, :integer
    add_index :tasks, %i[page_id position]
  end
end
