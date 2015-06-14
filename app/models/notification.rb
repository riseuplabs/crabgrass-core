#
# A notification informs users about an action that just took place.
#
# The users may be notified by different means - email, notice, etc.
# For now this will be hardcoded but it may be configurable for users at
# some point.
#
# For each thing that happens one Notification instance will inform
# all the recipients and may create many emails or notices.
#
#
class Notification

  attr_reader :event
  attr_reader :event_options

  # :group_destroyed, {group: @group, user: current_user}
  def initialize(event, event_options = {})
    @event = event
    @event_options = event_options
  end

  def deliver_mails_to(recipients, mailer_options = {})
    recipients.map do |recipient|
      Mailer.send "#{event}_notification", recipient, event_options, mailer_options
    end
  end

  def create_notices_for(recipients, notice_options = {})
    recipients.map do |recipient|
      create_notice notice_options.merge(user: recipient)
    end
  rescue NameError
    Rails.logger.warn "Warning: Notice class for '#{event}' is not defined."
  end

  def create_notice(attrs = {})
    class_name = "#{event}_notice"
    class_name.classify.constantize.create attrs
  end
end
