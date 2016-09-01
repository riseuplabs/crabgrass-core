class Geo::Location < ActiveRecord::Base
  self.table_name = 'geo_locations'

  belongs_to :geo_country, class_name: 'Geo::Country'
  validates_presence_of :geo_country_id

end
