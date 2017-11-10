class DropEmailAddresses < ActiveRecord::Migration
  def up
    drop_table :email_addresses
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
