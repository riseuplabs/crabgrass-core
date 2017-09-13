class Geo::AdminCode < ActiveRecord::Base
  self.table_name = 'geo_admin_codes'

  validates_presence_of :geo_country_id, :admin1_code, :name
  belongs_to :geo_country, class_name: 'Geo::Country'
  has_many :geo_places, class_name: 'Geo::Places'
end
