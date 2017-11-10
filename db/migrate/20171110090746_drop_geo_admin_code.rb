class DropGeoAdminCode < ActiveRecord::Migration
  def up
    drop_table :geo_admin_codes
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
