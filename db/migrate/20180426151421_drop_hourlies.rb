class DropHourlies < ActiveRecord::Migration
  def change
    drop_table :hourlies
  end

  def down
    fail ActiveRecord::IrreversibleMigration
   end
end
