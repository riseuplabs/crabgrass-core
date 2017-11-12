class DropLocations < ActiveRecord::Migration
  def up
    drop_table :locations
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
