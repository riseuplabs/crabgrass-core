# Any time a view needs to specify some javascript, it should use a helper here instead.
# This way, if we need to switch javascript libraries, we can just edit the code here.

module Common::Ui::JavascriptHelper

  ##
  ## rjs page updates
  ##

  def standard_update(page)
    update_alert_messages(page)
    if alert_messages_have_errors?
      hide_spinners(page)
    end
  end

  def hide_spinners(page)
    page.call 'hideSpinners'
  end

  ##
  ## dynamic styles
  ##

  #
  # set_style -- dynamically alter a global css rule
  #
  # most of the time it makes sense to alter the class or style of a particular
  # element when you want it to change. however, there are cases where you to
  # create or alter a global css rule dynamically via javascript.
  #
  # this is currently used by the page searching system.
  #
  # requires crabgrass's javascript class 'Style'
  #
  #def set_style(selector, css)
  #  id = selector.downcase.gsub(' ','_').gsub(/[^a-z0-9_]/,'') + '_dynamic_style'
  #  "Style.set('%s','%s {%s}');" % [id, selector, css]
  #end
  #
  #def clear_style(selector)
  #  id = selector.downcase.gsub(' ','_').gsub(/[^a-z0-9_]/,'') + '_dynamic_style'
  #  "Style.clear('%s');" % id
  #end

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
    function = "RequestQueue.add("

    # argument 1: url
    url_options = options[:url]
    url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
    function << "'#{escape_javascript(url_for(url_options))}'"

    # argument 2: options
    js_options = build_callbacks(options)
    if method = options[:method]
      method = "'#{method}'" unless (method.is_a?(String) and !method.index("'").nil?)
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
    if parameters
      function << ", '#{escape_javascript(parameters)}'"
    end

    # close function call
    function << ")"

    # after, before or condition
    function = "#{options[:before]}; #{function}" if options[:before]
    function = "#{function}; #{options[:after]}"  if options[:after]
    function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]

    return function
  end

  ##
  ## dom basics
  ##

  def dom_loaded
    concat "document.observe('dom:loaded',function(){"
    yield
    concat "});"
  end

  ##
  ## visibility
  ##

  # produces javascript to hide the given id or object
  def hide(id, extra=nil)
    id = dom_id(id,extra) if id.is_a?(ActiveRecord::Base)
    "$('%s').hide();" % id
  end

  # produces javascript to show the given id or object
  def show(id, extra=nil)
    id = dom_id(id,extra) if id.is_a?(ActiveRecord::Base)
    "$('%s').show();" % id
  end

  def hide_spinner(id)
    "$('%s').hide();" % spinner_id(id)
  end
  def show_spinner(id)
    "$('%s').show();" % spinner_id(id)
  end

  def activate_panel_row(item, load_url_function)
    loader = case load_url_function
             when String
               load_url_function
             when Proc
               url = load_url_function.call(item)
               remote_function(:url => url, :method => :get) + ";\n"
             else
               ''
             end
    loader + "activatePanelRow('#{dom_id(item)}');".html_safe
  end

  #
  # called when a user clicks on a row in a 'sliding list'
  #

  def activate_sliding_row(url)
    #left_domid = 'content'
    #right_domid = 'sliding-item'
    #right_path = url
    #"activateSlidingRow({domid:'%s',path:window.location.pathname}, {domid:'%s',path:'%s'})" %
    #  [left_domid, right_domid, right_path]

    "window.location.href = '%s'" % url
  end

  # we'll hopefully migrate to jquery soon - so i don't feel like
  # cleaning this mess up now.
  def tab_remote_function(options, tab = nil)
    options.reverse_merge! :method => :get,
      :success => ''
    options[:success] += 'tabLink.removeClassName("spinner_icon icon");'
    return <<-EOJS
      var tabLink = #{get_dom_element(tab, :tab)};
      #{remote_function(options)};
      activateTabLink(tabLink, true);
    EOJS
  end

  #
  # returns a string that will get a prototype extended dom element.
  #
  def get_dom_element(identifier, context = nil)
    case identifier
    when ActiveRecord::Base
      "$('#{dom_id(identifier, context)}')"
    when nil
      '$(this)'
    when /^\$\(/  # already uses prototype
      identifier
    when String
      "$('#{identifier}')"
    end
  end

  ##
  ## classes
  ##

  def replace_class_name(element_id, old_class, new_class)
    if element_id.is_a? String
      if element_id != 'this'
        element_id = "$('" + element_id + "')"
      end
    else
      element_id = "$('" + dom_id(element_id) + "')"
    end
    "replaceClassName(#{element_id}, '#{old_class}', '#{new_class}');"
  end

  def add_class_name(element_id, class_name)
    unless element_id.is_a? String
      element_id = dom_id(element_id)
    end
    "$('%s').addClassName('%s');" % [element_id, class_name]
  end

  def remove_class_name(element_id, class_name)
    unless element_id.is_a? String
      element_id = dom_id(element_id)
    end
    "$('%s').removeClassName('%s');" % [element_id, class_name]
  end

  ##
  ## MISC
  ##

  def replace_html(element_id, html)
    element_id = dom_id(element_id) unless element_id.is_a?(String)
    %[$('%s').update(%s);] % [element_id, html.inspect]
  end

  def dom_loaded_javascript_tag(javascript)
    javascript_tag %Q[
      document.observe('dom:loaded', function() {
        #{javascript}
      })
    ]
  end

  def reset_form(id)
    "$('#{id}').reset();"
    # "Form.getInputs($('#{id}'), 'submit').each(function(x){x.disabled=false}.bind(this));"
  end

  # add to text area or input field onkeypress attribute
  # to keep Enter key from submiting the form
  def eat_enter
    "return(!enterPressed(event));"
  end

  # used with text input elements that have some value set which acts like help text
  # it disappears when user focues on the input
  def show_default_value
    "if(this.value=='') this.value=this.defaultValue;"
  end

  def hide_default_value
    "if(this.value==this.defaultValue) this.value='';"
  end

  # toggle all checkboxes off and then toggle a subset of them on
  # selectors are css expressions
  #def checkboxes_subset_function(all_selector, subset_selector)
  #  "toggleAllCheckboxes(false, '#{all_selector}'); toggleAllCheckboxes(true, '#{subset_selector}')"
  #end
end

