class DropChannelsUsers < ActiveRecord::Migration
  def up
    drop_table :channels_users
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
