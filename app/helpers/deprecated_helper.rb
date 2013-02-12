## FIXME: get rid of this and use regular rails helpers
module DeprecatedHelper

  def link_to_remote(name, options = {}, html_options = nil)
    link_to_function(name, remote_function(options), html_options || options.delete(:html))
  end

  def submit_to_remote(name, value, options = {})
    options[:with] ||= 'Form.serialize(this.form)'

    html_options = options.delete(:html) || {}
    html_options[:name] = name

    button_to_remote(value, options, html_options)
  end

  def button_to_remote(name, options = {}, html_options = {})
    button_to_function(name, remote_function(options), html_options)
  end

  def button_to_function(name, function=nil, html_options={})
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function};"

    tag(:input, html_options.merge(:type => 'button', :value => name, :onclick => onclick))
  end

  def remote_function(options)
    javascript_options = options_for_ajax(options)

    update = ''
    if options[:update] && options[:update].is_a?(Hash)
      update  = []
      update << "success:'#{options[:update][:success]}'" if options[:update][:success]
      update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
      update  = '{' + update.join(',') + '}'
    elsif options[:update]
      update << "'#{options[:update]}'"
    end

    function = update.empty? ?
    "new Ajax.Request(" :
      "new Ajax.Updater(#{update}, "

    url_options = options[:url]
    function << "'#{html_escape(escape_javascript(url_for(url_options)))}'"
    function << ", #{javascript_options})"

    function = "#{options[:before]}; #{function}" if options[:before]
    function = "#{function}; #{options[:after]}"  if options[:after]
    function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
    function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]

    return function.html_safe
  end

end
