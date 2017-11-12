class DropProfileNotes < ActiveRecord::Migration

  def up
    drop_table :profile_notes
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
