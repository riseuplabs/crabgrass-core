class RemoveGeonameidFromGeoPlaces < ActiveRecord::Migration
  def change
    remove_column :geo_places, :geonameid, :integer, null: false
  end
end
