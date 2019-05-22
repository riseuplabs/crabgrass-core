# Any time a view needs to specify some javascript, it should use a helper here instead.
# This way, if we need to switch javascript libraries, we can just edit the code here.

module Common::Ui::JavascriptHelper
  ##
  ## rjs page updates
  ##

  def standard_update(page)
    update_alert_messages(page)
    hide_spinners(page) if alert_messages_have_errors?
  end

  def hide_spinners(page)
    page.call 'hideSpinners'
  end

  ##
  ## request queueing
  ##

  #
  # this method is like remote_function except that it generates a queued
  # ajax request. This queued request will not fire off until all the other
  # requests in the queue before it have completed.
  #
  # this is currently used by the ajax page searching system.
  #
  # requires crabgrass's javascript class 'RequestQueue'
  #
  def queued_remote_function(options)
    # open function call
    function = 'RequestQueue.add('

    # argument 1: url
    url_options = options[:url]
    url_options = url_options.merge(escape: false) if url_options.is_a?(Hash)
    function << "'#{escape_javascript(url_for(url_options))}'"

    # argument 2: options
    js_options = build_callbacks(options)
    if method = options[:method]
      method = "'#{method}'" unless method.is_a?(String) and !method.index("'").nil?
      js_options['method'] = method
    end
    javascript_options = options_for_javascript(js_options)
    function << ", #{javascript_options}"

    # argument 3: parameters
    parameters = options.delete(:with)
    if protect_against_forgery?
      if parameters
        parameters << " + '&"
      else
        parameters = "'"
      end
      parameters << "#{request_forgery_protection_token}=' + encodeURIComponent('#{escape_javascript form_authenticity_token}')"
    end
    function << ", '#{escape_javascript(parameters)}'" if parameters

    # close function call
    function << ')'

    # after, before or condition
    function = "#{options[:before]}; #{function}" if options[:before]
    function = "#{function}; #{options[:after]}"  if options[:after]
    function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]

    function
  end

  ##
  ## visibility
  ##

  # produces javascript to hide the given id or object
  def hide(id, extra = nil)
    id = dom_id(id, extra) if id.is_a?(ActiveRecord::Base)
    "$('%s').hide();".html_safe % id
  end

  # produces javascript to show the given id or object
  def show(id, extra = nil)
    id = dom_id(id, extra) if id.is_a?(ActiveRecord::Base)
    "$('%s').show();".html_safe % id
  end

  # produces javascript to show the given id or object
  def toggle(id, extra = nil)
    id = dom_id(id, extra) if id.is_a?(ActiveRecord::Base)
    "$('%s').toggle();".html_safe % id
  end

  def remove(id, extra = nil)
    id = dom_id(id, extra) if id.is_a?(ActiveRecord::Base)
    "$('%s').remove();".html_safe % id
  end

  def hide_spinner(id)
    format("$('%s').hide();", spinner_id(id))
  end

  def show_spinner(id)
    format("$('%s').show();", spinner_id(id))
  end

  ##
  ## MISC
  ##

  # submits the named formed and eats the event.
  # e.g. :onkeydown => submit_form(x)
  def submit_form(id)
    "if (enterPressed(event)) {$('#{id}').submit.click(); event.stop();}"
  end

  # add to text area or input field onkeypress attribute
  # to keep Enter key from submiting the form
  def eat_enter
    'return(!enterPressed(event));'
  end

  def focus_form(id)
    javascript_tag "Form.focusFirstElement('#{id}');"
  end

end
