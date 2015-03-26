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
        if alert_messages?
          safe_join(alert_message_strings)
        else
          ""
        end
      end
    end
  end

  #
  # generates html for the inline alert messages
  #
  def inline_alert_messages
    if alert_messages?
      html = safe_join(alert_message_strings(false))
      clear_alert_messages # if display inline, we want ensure they are not also floating.
      html
    else
      ""
    end
  end

  def alert_messages?
    flash[:messages].present?
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
    if alert_messages?
      page.call 'showAlertMessage', display_alert_messages
    else
      page.call 'showAlertMessage', ''
    end
  end

  ##
  ## DISPLAY
  ##

  def alert_message_strings(allow_fade = true)
    flash[:messages].collect do |message|
      message_html(message, allow_fade)
    end
  end

  #
  # generate html for a single message line.
  #
  # message is a hash with these keys:
  #
  #  :type -- one of :error, :warning, :notice, :success
  #  :text -- a string or array of strings to display. (optional)
  #  :list -- an array of strings to be used in a bulleted list
  #  :fade -- if true, force fading of this message
  #  :quick -- faster fading
  #  :nofade -- if true, force no fade
  #
  # if allow_fade is false, then we ignore :fade and :nofade options
  #
  def message_html(message, allow_fade = true)
    #icon_class = case message[:type]
    #  when :error   then 'caution_16'
    #  when :warning then 'exclamation_16'
    #  when :notice  then 'lightbulb_16'
    #  when :success then 'ok_16'
    #end
    alert_class = case message[:type]
      when :error   then 'alert alert-danger'
      when :warning then 'alert alert-warning'
      when :notice  then 'alert alert-info'
      when :success then 'alert alert-success'
    end
    message_id = "alert_message_#{rand(100_000_000)}"
    text = if message[:text].is_a?(Array)
      if message[:text].size > 1
        content_tag(:p, message[:text][0], class: 'first') +
        content_tag(:p, message[:text][1..-1].join)
      else
        message[:text].first
      end
    else
      message[:text]
    end
    html = []
    html << link_to_function('×', "hideAlertMessage('#{message_id}')", class: 'close')
    html << content_tag(:div, text, class: "text")
    if message[:list]
      html << content_tag(:ul,
        safe_join(message[:list].collect{|item|
          content_tag(:li, item)
        })
      )
    end
    if allow_fade
      if message[:fade] || message[:quick] || ((message[:type] == :success || message[:type] == :notice) && !message[:nofade])
        timeout = message[:quick] ? 0.5 : FADE_TIMEOUT
        html << content_tag(:script, "hideAlertMessage('#{message_id}', #{timeout});".html_safe)
      end
    end
    content_tag(:div, html.join.html_safe, class: alert_class, id: message_id)
  end

end

