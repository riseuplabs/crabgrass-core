class DropEventRecurrencies < ActiveRecord::Migration
  def up
    drop_table :event_recurrencies
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
