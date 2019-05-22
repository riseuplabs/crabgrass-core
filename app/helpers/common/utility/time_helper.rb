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

  # formats a time, in full detail
  # for example: Sunday 2007/July/3 2:13PM PST
  def full_time(time)
    I18n.locale == :en ?
      time.strftime('%A %Y/%b/%d %I:%M%p') :
      I18n.l(time)
  end
end
