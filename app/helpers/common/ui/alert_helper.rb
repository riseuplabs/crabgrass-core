# encoding: utf-8
#
##
## DISPLAYING ALERTS
##

module Common::Ui::AlertHelper

  FADE_TIMEOUT = 5;

  #
  # generates the html for the floating alert messages
  #
  def display_alert_messages
    # the id alert_messages is required by the showAlertMessage
    # javascript function. it is important to include this html
    # even if ther are not currently any messages to display.
    content_tag(:div, class: 'alert_message_container') do
      content_tag(:div, id: 'alert_messages') do
        render_alert_messages
      end
    end
  end

  #
  # generates html for the inline alert messages
  #
  def inline_alert_messages
    render_alert_messages(false).tap do
      clear_alert_messages # if display inline, we want ensure they are not also floating.
    end
  end

  def alert_messages_have_errors?
    flash[:messages].present? &&
      flash[:messages].detect {|m| m[:type] == :error or m[:type] == :warning}
  end

  def clear_alert_messages
    if Rails.env == 'test'
      # for testing it is useful to have the messages.
      flash[:hidden_messages] = flash[:messages]
    end
    flash[:messages] = nil
  end

  #
  # A helper for rjs templates. Put this at the top of the template:
  #
  #  update_alert_messages(page)
  #
  # In order to show any messages that might be set, or to hide the message
  # area if there are none set.
  #
  # Note: this is included in the method standard_update(), which is better to use
  # because it also will stop all spinners.
  #
  def update_alert_messages(page)
    page.call 'showAlertMessage', render_alert_messages
  end

  ##
  ## DISPLAY
  ##

  def render_alert_messages(allow_fade = true)
    render partial: 'ui/alert',
      collection: flash[:messages],
      locals: {allow_fade: allow_fade, timeout: FADE_TIMEOUT}
  end

end

