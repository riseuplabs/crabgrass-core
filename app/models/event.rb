class Event < ActiveRecord::Base
  has_many :pages, as: :data
  format_attribute :description

  #  validates_presence_of :starts_at # only commented out to test
  ##  validates_presence_of :ends_at # only commented out to test

  # delegate :owner_name, :to => :page # only commented out to test

  # def page
  #  pages.first || parent_page
  # end

  # def page=(p)
  #  @page = p
  # end

  def index
    description
  end

  def self.on_day(date)
    start_unix = Time.utc(date.year, date.month, date.day, 0, 0, 0).to_i
    end_unix = Time.utc(date.year, date.month, date.day, 23, 59, 59).to_i
    between_dates(start_unix, end_unix)
  end

  def self.in_month(date)
    start_unix = Time.utc(date.year, date.month, 1, 0, 0, 0).to_i
    end_day = Date.civil(date.year, date.month, -1)
    end_unix = Time.utc(end_day.year, end_day.month, end_day.day, 23, 59, 59).to_i
    between_dates(start_unix, end_unix)
  end

  private

  def self.between_dates(start_unix, end_unix)
    where 'UNIX_TIMESTAMP(starts_at) >= ? and UNIX_TIMESTAMP(starts_at) <= ?',
          start_unix, end_unix
  end
end
