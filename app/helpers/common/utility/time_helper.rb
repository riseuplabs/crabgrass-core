module Common::Utility::TimeHelper
  protected

  #
  # friendly_date()
  #
  # Our goal here it to automatically display the date in the way that
  # makes the most sense. Elusive, i know. If an array of times is passed in
  # we display the newest one.
  #
  # Here are the current options:
  #
  #   4:30PM    -- time was today
  #   Wednesday -- time was within the last week.
  #   Mar 7     -- time was in the current year (depends on current locale)
  #   Mar 7 08  -- time was in a different year (depends on current locale)
  #
  # The date is then wrapped in a label, so that if you hover over the text
  # you will see the full details.
  #
  # NOTE: unfortunately, I think this method is incredibly slow, adding about 100ms
  # if called on a table of dates. I don't think this is avoidable: formatting times
  # just takes a lot of logic.
  #

  WeekdaySymbols = %i[sunday monday tuesday wednesday thursday friday saturday].freeze

  def friendly_date(time, options = {})
    return '' if time.nil?
    classes = [:date]
    classes += [:icon, "#{options[:icon]}_16"] if options[:icon]
    content_tag :span,
                short_date(time, true),
                class: classes,
                title: l(time)
  end

  def friendly_time(time, format = :long)
    I18n.l time, format: format
  end

  def short_date(time, html = false)
    @today ||= Time.zone.today
    date = time.to_date

    if date == @today
      # 4:30PM
      format = html ? '%l:%M<span>%p</span>' : '%l:%M %p'
      time.strftime(format).html_safe
    elsif @today > date and (@today - date) < 7
      # I18n.t(:wednesday) => Wednesday
      I18n.t(WeekdaySymbols[time.wday])
    elsif date.year != @today.year
      # 7/Mar/08
      I18n.l date
    else
      # 7/Mar
      I18n.l date, format: :short
    end
  end

  def localize_month(month)
    # for example => :month_short_january
    month_sym = ('month_short_' + month.downcase).to_sym
    I18n.t(month_sym)
  end

  # formats a time, in full detail
  # for example: Sunday 2007/July/3 2:13PM PST
  def full_time(time)
    I18n.locale == :en ?
      time.strftime('%A %Y/%b/%d %I:%M%p') :
      I18n.l(time)
  end

  def full_date(date)
    date.strftime('%A %d/%b/%Y')
  end

  def to_utc(time)
    Time.zone.local_to_utc(time)
  end

  def local_now
    Time.zone.now
  end

  def after_day_start?(time)
    local_now.at_beginning_of_day < time
  end

  def after_yesterday_start?(time)
    local_now.yesterday.at_beginning_of_day < time
  end

  def after_week_start?(time)
    (local_now.at_beginning_of_day - 7.days) < time
  end

  ##
  ## This are used as a cheap time based expiry of fragment caches.
  ##
  ## for example:
  ##   cache(:expires_in => hours(3))
  ##
  ## this does NOT actually expire the fragment cache, but it makes it invalid
  ## after three hours, which is just as good so long as you have an external
  ## job that cleans up after old files.
  ##

  def hours(num)
    (Time.now.to_i / num.hour).floor
  end

  def days(num)
    (Time.now.to_i / num.days).floor
  end

  ##############################################
  ## UI helpers

  def calendar_tag(_field_id, date = nil)
    include_calendar_tags
    calendar_date_select_tag(date ? date.to_date.to_formatted_s(:long) : nil)
  end

  def include_calendar_tags
    unless @calendar_tags_included
      @calendar_tags_included = true
      content_for :end_tags do
        calendar_date_select_includes 'default'
      end
    end
  end
end
