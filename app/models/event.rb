class Event < ActiveRecord::Base

  has_many :pages, :as => :data
  format_attribute :description

  #validates_presence_of :location
  #  validates_presence_of :starts_at # only commented out to test
 ##  validates_presence_of :ends_at # only commented out to test

  #delegate :owner_name, :to => :page # only commented out to test

  #def page
  #  pages.first || parent_page
  #end

  #def page=(p)
  #  @page = p
  #end

  def index
    self.description
  end

end
