require 'test_helper'

class Geo::LocationTest < ActiveSupport::TestCase
  def test_country_id_required
    geo_location = Geo::Location.new
    assert !geo_location.save, 'Saved GeoLocation without country id.'
  end
end
