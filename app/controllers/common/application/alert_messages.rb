# this requires ActionView::Helpers::TagHelper
#
# Four different alert methods:
#
#  error()   -- when something has gone horribly wrong. RED
#  warning() -- bad input or permissioned denied. YELLOW
#  notice()  -- information, but not necessarily bad or good. BLUE.
#  success() -- yeah, confirmation that something went right. GREEN.
#
# If message is empty, these standard messages are shown:
#
#  error: "Changes could not be saved"
#  warning: "Changes could not be saved"
#  notice: no default
#  success: "Changes saved"
#
# The alert methods accept arguments, in any order, that are Strings, Exceptions,
# Arrays or Symbols.
#
# Exception    -- display an alert appropriate to the exception.
# String       -- displays the content of the string.
# Array        -- displays each of the strings in the array, each on their own line.
# ActiveRecord -- displays the validation errors for the object.
# Symbol       -- set options with the alert message:
#
#    Available options:
#      :now    -- flash now
#      :later  -- flash later
#      :fade   -- hide message after 5 seconds
#                 (by default, success and notice messages fade.)
#      :quick  -- fade, but start immediately.
#      :nofade -- prevent fade
#
# Flash now or flash later? The code tries to pick an intelligent default:
#
# Flash now:
#  - ajax requests
#  - post/put with error
#
# Flash later
#  - @preformed_redirect is true
#  - get requests
#  - post/put with success
#
# NOTE: i think @preformed_redirect is undocumented and might change in the future.
#

require 'active_support/multibyte/chars'

module Common::Application::AlertMessages

  FADE_TIMEOUT = 5;

  def self.included(base)
    base.class_eval do
      # settings alerts
      helper_method :error
      helper_method :warning
      helper_method :notice
      helper_method :success
      helper_method :raise_error
      helper_method :raise_not_found
      helper_method :raise_denied

      # display
      helper_method :alert_messages?
      helper_method :alert_messages_have_errors?
      helper_method :display_alert_messages
      helper_method :inline_alert_messages
      helper_method :clear_alert_messages
      helper_method :update_alert_messages
    end
  end

  protected

  ##
  ## GENERATING ALERTS
  ##

  def error(*args)
    alert_message(:error, *args)
  end

  def warning(*args)
    alert_message(:warning, *args)
  end

  def notice(*args)
    alert_message(:notice, *args)
  end

  def success(*args)
    alert_message(:success, *args)
  end

  def alert_message(*args)
    options = Hash[args.collect {|i|i.is_a?(Symbol) ? [i,true] : nil}]
    type = determine_type(options)
    flsh = determine_flash(type, options)
    flsh[:messages] ||= []
    add_flash(type, *args).each do |msg|
      # allow options to override the defaults
      flsh[:messages] << msg.merge(options);
    end
  end

  #
  # forces the alert messages to come later, even if we previously said :now.
  # this is used in case we did :now but then redirected later.
  #
  def force_later_alert()
    flash[:messages] = flash.now[:messages]
  end

  ##
  ## DISPLAYING ALERTS
  ##

  #
  # generates the html for the floating alert messages
  #
  def display_alert_messages
    # the id alert_messages is required by the showAlertMessage
    # javascript function. it is important to include this html
    # even if ther are not currently any messages to display.
    content_tag(:div, :class => 'alert_message_container') do
      content_tag(:div, :id => 'alert_messages') do
        if alert_messages?
          flash[:messages].collect {|message| message_html(message)}.join
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
      html = flash[:messages].collect do |message|
        message_html(message, false)
      end.join
      clear_alert_messages # if display inline, we want ensure they are not also floating.
      html
    else
      ""
    end
  end

  def alert_messages?
    flash[:messages].any?
  end

  def alert_messages_have_errors?
    flash[:messages].any? and flash[:messages].detect {|m| m[:type] == :error or m[:type] == :warning}
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
  # in order to show any messages that might be set, or to hide the message
  # area if there are none set.
  #
  def update_alert_messages(page)
    if alert_messages?
      page.call 'showAlertMessage', display_alert_messages
    else
      page.call 'showAlertMessage', ''
    end
  end

  def raise_error(message)
    if message.is_a? ActiveRecord::Base
      raise ActiveRecord::RecordInvalid.new(message)
    else
      raise ErrorMessage.new(message)
    end
  end

  def raise_not_found(thing)
    raise ErrorNotFound.new(thing)
  end

  def raise_denied(message=nil)
    raise PermissionDenied.new(message)
  end

  def raise_authentication_required
    raise AuthenticationRequired.new
  end

  private

  ##
  ## BUILDING THE MESSAGE
  ##

  def add_flash(type, *args)
    if exception = args.detect{|a|a.is_a? Exception}
      add_flash_exception(exception)
    elsif record = args.detect{|a|a.is_a? ActiveRecord::Base}
      add_flash_record(record, args.extract_options!)
    elsif (messages = args.select{|a| a.is_a?(String) or a.is_a?(ActiveSupport::Multibyte::Chars)}).any?
      add_flash_message(type, messages)
    elsif message_array = args.detect{|a| a.is_a?(Array)}
      add_flash_message(type, message_array)
    else
      add_flash_default(type)
    end
  end

  def add_flash_message(type, message)
    [{:type => type, :text => message}]
  end

  def add_flash_default(type)
    msg = if(type == :error or type == :warning)
      :alert_not_saved.t;
    else
      :alert_saved.t;
    end
    add_flash_message(type, msg)
  end

  def add_flash_exception(exception)
    if exception.is_a? PermissionDenied
      [{:type => :warning, :text => [:alert_permission_denied.t, :permission_denied_description.t]}]
    elsif exception.is_a? AuthenticationRequired
      [{:type => :notice, :text => [:login_required.t, :login_required_description.t]}]
    elsif exception.is_a? ErrorMessages
      exception.errors.collect do |msg|
        {:type => :error, :text => msg}
      end
    elsif exception.is_a? ActiveRecord::RecordInvalid
      add_flash_record(exception.record)
    else
      [{:type => :error, :text => exception.to_s}]
    end
  end

  def add_flash_record(record, options = {})
    if record.respond_to?(:flash_message) && record.flash_message
      options[:count] ||= 1
      [ record.flash_message(options) ]
    elsif record.errors.any?
      [{ :type => :error,
         :text => [:alert_not_saved.t, :alert_field_errors.t],
         :list => record.errors.full_messages }]
    else
      [{ :type => :success,
         :text => :alert_saved.t }]
    end
  end

  #
  # make a good guess as to what kind of flash we want, and allow an overide
  #
  def determine_flash(type, options)
    if options[:now]
      flash.now
    elsif options[:later]
      flash
    elsif @performed_redirect
      flash
    elsif (request.post? or request.put?) and (type == :error or type == :warning)
      flash.now
    elsif request.xhr?
      flash.now
    else
      flash
    end
  end

  def determine_type(options)
    if options[:error];      :error
    elsif options[:warning]; :warning
    elsif options[:notice];  :notice
    elsif options[:success]; :success
    end
  end

  ##
  ## DISPLAY
  ##

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
    icon_class = case message[:type]
      when :error   then 'caution_16'
      when :warning then 'exclamation_16'
      when :notice  then 'lightbulb_16'
      when :success then 'ok_16'
    end
    message_id = "alert_message_#{rand(100_000_000)}"
    text = if message[:text].is_a?(Array)
      if message[:text].size > 1
        content_tag(:p, message[:text][0], :class => 'first') +
        content_tag(:p, message[:text][1..-1])
      else
        message[:text].first
      end
    else
      message[:text]
    end
    html = []
    html << view.link_to_function('×', "hideAlertMessage('#{message_id}')", :class => 'close')
    html << content_tag(:div, text, :class => "text #{icon_class}")
    if message[:list]
      html << content_tag(:ul, message[:list].collect{|item|content_tag(:li, item)})
    end
    if allow_fade
      if message[:fade] || message[:quick] || ((message[:type] == :success || message[:type] == :notice) && !message[:nofade])
        timeout = message[:quick] ? 0.5 : FADE_TIMEOUT
        html << content_tag(:script, "hideAlertMessage('#{message_id}', #{timeout});")
      end
    end
    content_tag(:div, html.join, :class => "message #{message[:type]}", :id => message_id)
  end

#  def exception_detailed_message(exception=nil)
#    return "Warning: Trying to get detailed message but no exception given." unless exception
#    message = exception.clean_message
#    file, line = exception.backtrace.first.split(":")[0, 2]
#    if File.exists?(file)
#      message << "\n\n"
#      code = File.readlines(file)
#      line = line.to_i
#      min = [line - 2, 0].max
#      max = line + 2
#      (min..max).each do |n|
#        if n == line
#          message << "=> "
#        else
#          message << "   "
#        end
#        message << ("%4d" % n)
#        message << code[n].to_s
#      end
#    end
#    message
#  end

end

