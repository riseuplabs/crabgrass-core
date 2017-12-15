class DropSettings < ActiveRecord::Migration
  def up
    drop_table :user_settings
    drop_table :group_settings
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
