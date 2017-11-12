class DropChannels < ActiveRecord::Migration
  def up
    drop_table :channels
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
