class DropGeoPlace < ActiveRecord::Migration
  def up
    drop_table :geo_places
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
