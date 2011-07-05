require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase

  def setup
    @today = Time.new
    start = Time.utc(@today.year, @today.month, @today.day, Time.new.hour, Time.new.min, Time.new.sec)
    end_at = Time.at(start.to_i + 200)
    5.times do
      Event.create!(:starts_at => start.to_s, :ends_at => end_at.to_s)
    end

    @next_month = Time.new.advance(:months => 1) 
    start = Time.utc(@next_month.year, @next_month.month, @next_month.day, Time.new.hour, Time.new.min, Time.new.sec)
    end_at = Time.at(start.to_i + 200)
    4.times do
      Event.create!(:starts_at => start.to_s, :ends_at => end_at.to_s)
    end
  end

  def test_creation
    start = Time.at(Time.new.to_i)
    end_at = Time.at(Time.new.to_i + 200)
    event = Event.create!(:starts_at => start.to_s, :description => 'description', :ends_at => end_at.to_s )
    assert !event.nil?
  end

  def test_view_events_today
    assert_equal 5, Event.on_day(@today).size
  end

  def test_view_events_other_day
    assert_equal 4, Event.on_day(@next_month).size
  end

  def test_view_events_this_month
    assert_equal 5, Event.in_month(@today).size
  end

  def test_view_events_other_month
    assert_equal 4, Event.in_month(@next_month).size
  end

end
