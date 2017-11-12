class DropPhoneNumbers < ActiveRecord::Migration
  def up
    drop_table :phone_numbers
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
