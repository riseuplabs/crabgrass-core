class DropGeoLocation < ActiveRecord::Migration
  def up
    drop_table :geo_locations
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
