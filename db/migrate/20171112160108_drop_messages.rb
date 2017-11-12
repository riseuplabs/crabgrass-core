class DropMessages < ActiveRecord::Migration
  def up
    drop_table :messages
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
