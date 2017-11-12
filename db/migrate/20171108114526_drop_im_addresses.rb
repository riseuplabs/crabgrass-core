class DropImAddresses < ActiveRecord::Migration
  def up
    drop_table :im_addresses
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
