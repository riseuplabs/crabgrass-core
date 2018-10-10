class DropEvents < ActiveRecord::Migration
  def up
    drop_table :events
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
