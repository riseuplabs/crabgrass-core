class DropGeoCountry < ActiveRecord::Migration
  def up
    drop_table :geo_countries
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
