class DropDailies < ActiveRecord::Migration
  def change
    drop_table :dailies
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
