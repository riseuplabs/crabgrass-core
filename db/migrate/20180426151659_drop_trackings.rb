class DropTrackings < ActiveRecord::Migration
  def change
    drop_table :trackings
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
