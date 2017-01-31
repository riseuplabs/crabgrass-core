class Geo::Country < ActiveRecord::Base
  self.table_name = 'geo_countries'

  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code
  has_many :geo_admin_codes, class_name: 'Geo::AdminCode'
  has_many :geo_places, class_name: 'Geo::Place'

  def self.with_public_profile
    joins('AS gc JOIN geo_locations AS gl ON gc.id = gl.geo_country_id').
    select('gc.name, gc.id')
  end

end
