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
# The alert methods accept Strings, Exceptions, and Symbols. 
# Symbols are used to set options.
#
# Available options:
#   :now    -- flash now
#   :later  -- flash later
#   :fade   -- hide message after about 5 seconds
#   :nofade -- prevent fade
#
# Flash now or flash later? The code tries to pick an intelligent default:
#
# Flash now:
#  - ajax requests
#  - post with error
# Flash later
#  - get requests
#  - post with success
#
#

require 'active_support/multibyte/chars'

module ControllerExtension::AlertMessages

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
      helper_method :display_alert_messages
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

  ##
  ## DISPLAYING ALERTS
  ##

  # generates the html for the alert messages
  def display_alert_messages(include_container = true)
    inner = if alert_messages?
      flash[:messages].collect {|message| message_html(message)}.join
    else
      ""
    end
    
    if include_container
      content_tag(
        :div,
        content_tag(:div, inner, :id => 'alert_message_list', :class => 'alert_message_list'),
        :class => 'alert_message_container'
      )
    else
      inner
    end
  end

  def alert_messages?
    flash[:messages].any?
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
      page.call 'showAlertMessage', display_alert_messages(false)
    else
      page.call 'showAlertMessage', ''
    end
  end

  def raise_error(message)
    raise ErrorMessage.new(message)
  end

  def raise_not_found(message)
    raise ErrorNotFound.new(message)
  end

  def raise_denied(message=nil)
    raise PermissionDenied.new(message)
  end

  private

  ##
  ## BUILDING THE MESSAGE
  ##

  def alert_message(type, *args)
    options = Hash[args.collect {|i|i.is_a?(Symbol) ? [i,true] : nil}]
    flsh = determine_flash(type, options)
    flsh[:messages] ||= []
    add_flash(type, *args).each do |msg|
      # allow options to override the defaults
      flsh[:messages] << msg.merge(options);
    end
  end

  def add_flash(type, *args)
    if exception = args.detect{|a|a.is_a? Exception}
      add_flash_exception(exception)
    elsif record = args.detect{|a|a.is_a? ActiveRecord::Base}
      add_flash_record(record)
    elsif message = args.detect{|a|a.is_a?(String) or a.is_a?(ActiveSupport::Multibyte::Chars)}
      add_flash_message(type, message)
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
      [{:type => :warning, :text => :alert_permission_denied.t}]
    elsif exception.is_a? ErrorMessages
      exception.errors.collect do |msg|
        {:type => :error, :text => msg}
      end
    elsif exc.is_a? ActiveRecord::RecordInvalid
      add_flash_record(exc.record)
    else
      [{:type => :error, :text => exception.to_s}]
    end
  end

  def add_flash_record(record)
    if record.errors.any?
      [{ :type => :error,
         :text => [:alert_not_saved.t, :alert_field_errors.t],
         :list => object.errors.full_messages }]
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
    elsif request.post? and (type == :error or type == :warning)
      flash.now
    elsif request.xhr?
      flash.now
    else
      flash
    end
  end

  ##
  ## DISPLAY
  ##

  # generate html for a single message line.
  def message_html(message)
    icon_class = case message[:type]
      when :error then 'caution_16'
      when :warning then 'exclamation_16'
      when :notice then 'lightbulb_16'
      when :success then 'ok_16'
    end
    message_id = "alert_message_#{rand(100_000_000)}"
    html = []
    html << view.link_to_function('×', "hideAlertMessage('#{message_id}')", :class => 'close')
    html << content_tag(:div, message[:text], :class => "text #{icon_class}")
    if message[:list]
      html << content_tag(:ul, message[:list].collect{|item|content_tag(:li, item)})
    end
    if message[:fade] or ((message[:type] == :success or message[:type] == :notice) and !message[:nofade])
      html << content_tag(:script, "hideAlertMessage('#{message_id}', #{FADE_TIMEOUT});")
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

