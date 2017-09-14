class Geo::Place < ActiveRecord::Base
  self.table_name = 'geo_places'
  validates_presence_of :geo_country_id, :name
  belongs_to :geo_country, class_name: 'Geo::Country'
  belongs_to :geo_admin_code, class_name: 'Geo::AdminCode'

  def self.with_names_matching(name, country_id, params = {})
    geo_country = Geo::Country.find(country_id)
    if params[:admin_code_id] =~ /\d+/
      geo_admin_code = geo_country.geo_admin_codes.find(params[:admin_code_id])
      admin_codes = [geo_admin_code]
    else
      admin_codes = geo_country.geo_admin_codes.find(:all)
    end
    @places = []
    admin_codes.each do |ac|
      ### first search for exact- return that if found
      places = ac.geo_places.find_by_name(name)
      if places.is_a?(Array)
        places.each do |place|
          @places << place
        end
      elsif !places.nil?
        @places << places
      end
    end
    return @places unless @places.empty? or params[:search_alternates]
    ### search for LIKE in name and alternatenames
    admin_codes.each do |ac|
      @places << find(:all,
                      conditions: ['geo_admin_code_id = ? and (name LIKE ? or alternatenames LIKE ?)', ac.id, "%#{name}%", "%,#{name},%"])
    end
    @places.flatten!
  end
end
