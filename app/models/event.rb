class Event < ActiveRecord::Base

  has_many :pages, :as => :data
  format_attribute :description

  #validates_presence_of :location
  validates_presence_of :starts_at
  validates_presence_of :ends_at

  #delegate :owner_name, :to => :page

  #def page
  #  pages.first || parent_page
  #end

  #def page=(p)
  #  @page = p
  #end

  def index
    self.description
  end

  named_scope :on_day, lambda { |date|
    start_unix = Time.utc(date.year, date.month, date.day, 0, 0, 0).to_i
    end_unix = Time.utc(date.year, date.month, date.day, 23, 59, 59).to_i
    self.between_dates_condition(start_unix, end_unix)
  }

  named_scope :in_month, lambda { |date|
    start_unix = Time.utc(date.year, date.month, 1, 0, 0, 0).to_i
    end_day = Date.civil(date.year, date.month, -1)
    end_unix = Time.utc(end_day.year, end_day.month, end_day.day, 23, 59, 59).to_i
    self.between_dates_condition(start_unix, end_unix)
  }

  private

  def self.between_dates_condition(start_unix, end_unix)
    {:conditions => "UNIX_TIMESTAMP(starts_at) >= #{start_unix.to_s} and UNIX_TIMESTAMP(starts_at) <= #{end_unix.to_s}" }
  end

end
