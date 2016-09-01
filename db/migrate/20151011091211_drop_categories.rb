class DropCategories < ActiveRecord::Migration
  def up
    drop_table :categories
  end

  def down
    create_table :categories
  end
end
