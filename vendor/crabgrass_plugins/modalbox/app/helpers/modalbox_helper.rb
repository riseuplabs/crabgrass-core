#  Modalbox
#
# Displays a modal dialog box
#

module LinkWithConfirm

  ##
  ## USE MODALBOX FOR CONFIRM
  ##

  #
  # redefines link_to_remote to use Modalbox.confirm() if options[:confirm] is set.
  #
  # If cancel is pressed, then nothing happens.
  # If OK is pressed, then the remote function is fired off.
  #
  # While loading, the modalbox spinner is shown. When complete, the modalbox is hidden.
  #
  def link_to_remote_with_confirm(name, options = {}, html_options = {})
    message = if options.is_a?(Hash) and options[:confirm]
		options.delete(:confirm)
	      else
		html_options.delete(:confirm)
	      end

    if message
      ## if called when the modalbox is already open, it is important that we
      ## call back() before the other complete callbacks. Otherwise, the html
      ## they expect to be there might be missing.
      options[:loading] = ['Modalbox.spin()', options[:loading]].compact.join('; ')
      options[:loaded] = ['Modalbox.back()', options[:loaded]].compact.join('; ')
      ok_function = remote_function(options)
      link_to_function(name, %[Modalbox.confirm("#{message}", {ok_function:"#{ok_function}", title:"#{name}"})], html_options)
    else
      if options[:with] && options[:loading] && options[:complete]
        options[:data] = {with: options[:with], loading: options[:loading], complete: options[:complete]}
        options.delete(:with)
        options.delete(:loading)
        options.delete(:complete)
      end
      url = options[:url]
      options.delete(:url)
      options = options.merge({remote: true}).merge(html_options)
      link_to(name, url, options)
    end
  end

  #
  # redefines link_to to use Modalbox.confirm() if options[:confirm] is set.
  #
  # If cancel is pressed, then nothing happens.
  # If OK is pressed, then a form submit happens, using the action and method specified.
  #
  def link_to(name, options = {}, html_options = nil)
    if options.is_a?(Hash) and options[:confirm]
      # this seems like a bad form. the confirm should be in html_options.
      # is this really used anywhere?
      message = options[:confirm]
      action = options[:url]
      method = options[:method]
    elsif html_options.is_a?(Hash) and html_options[:confirm]
      action = options
      message = html_options.delete(:confirm)
      method = html_options.delete(:method)
      options = html_options
    else
      message = nil
    end

    if message
      method ||= 'post'
      token = form_authenticity_token
      action = url_for(action) if action.is_a?(Hash)
      ok = options[:ok] || I18n.t(:ok_button)
      title = options[:title] || name
      cancel = options[:cancel] || I18n.t(:cancel)
      link_to_function(name,
		       %[Modalbox.confirm("#{message}", {method:"#{method}", action:"#{action}", token:"#{token}", title:"#{title}", ok:"#{ok}", cancel:"#{cancel}"})],
		       html_options)
    else
      super(name, options, html_options)
    end
  end

end


module ModalboxHelper

  prepend LinkWithConfirm
  ##
  ## Modalbox dialog popup helpers
  ##

  #
  # creates a popup-link using modalbox
  #
  # contents of the modalbox may be specified in options hash:
  # - url: then contents for the modalbox are loaded via ajax
  # - html: the html is used to populate the modalbox
  #
  # if options[:icon], then the modalbox is not shown until after its contents
  # are loaded.
  #
  # for example:
  #
  #   link_to_modal('hi', {:url => '/some/popup/action'}, {:style => 'font-weight: bold'})
  #
  #
  def link_to_modal(label, options = {}, html_options = {})
    options[:title] ||= label
    icon = options.delete(:icon) || html_options.delete(:icon)
    if options[:html]
      static_html = true
      contents = options.delete(:html)
      unless contents =~ /<.+>/
        # ensure there are some tags in the html, otherwise modalbox
        # will not recognize it as html.
        contents = format('<p>%s</p>', contents)
      end
    elsif options[:url]
      static_html = false
      contents = options.delete(:url)
      contents = url_for contents if contents.is_a? Hash
    else
      raise ArgumentError.new 'must give :html or :url'
    end
    if icon
      html_options[:id] ||= format('link%s', rand(1_000_000))
      unless static_html
        # skip these ajax options if we are just directly showing some
        # static content.
        options.merge!(
          loading: spinner_icon_on(icon, html_options[:id]),
          complete: spinner_icon_off(icon, html_options[:id]),
          showAfterLoading: true
        )
      end
      html_options[:icon] = icon
    end
    function = modalbox_function(contents, options)
    link_to_function_with_icon(label, function, html_options)
  end

  # close the modal box
  def close_modal_button(label = nil)
    button_to_function((label == :cancel ? I18n.t(:cancel) : I18n.t(:close_button)), 'Modalbox.hide();', class: 'btn btn-default')
  end

  def cancel_modal_button
    close_modal_button(:cancel)
  end

  def back_modal_button
    button_to_function(:back.t, 'Modalbox.back();')
  end

  # to be called each and every time you have programmatically changed the size
  # of the modalbox.
  def resize_modal
    'Modalbox.updatePosition();'
  end

  def modalbox_function(contents, options)
    contents = escape_javascript(contents)
    format("Modalbox.show('%s', %s)", contents, options_for_modalbox_function(options))
  end

  def close_modal_function
    'Modalbox.hide();'
  end

  def localize_modalbox_strings
    format('Modalbox.setStrings(%s)', {
      ok: I18n.t(:ok_button), cancel: I18n.t(:cancel), close: I18n.t(:close_button),
      alert: I18n.t(:alert), confirm: I18n.t(:confirm), loading: I18n.t(:loading_progress)
    }.to_json)
  end

  private

  #
  # Takes a ruby hash and generates the text for a javascript hash.
  # This is kind of like hash.to_json(), except that callbacks are wrapped in
  # "function(n) {}" and sent raw instead of surrounded by quotes.
  #
  def options_for_modalbox_function(options)
    hash = {}

    # i tried making callbacks a constant, but then rails complains loudly.
    # not sure why...
    callbacks = %i[before_load after_load before_hide after_hide
                   after_resize on_show on_update]

    options.each do |key, value|
      if ActionView::Helpers::PrototypeHelper::CALLBACKS.include?(key)
        name = 'on' + key.to_s.capitalize
        hash[name] = "function(request){#{value}}"
      elsif callbacks.include?(key)
        name = key.to_s.camelize
        name[0] = name.at(0).downcase
        hash[name] = "function(request){#{value}}"
      elsif value === true or value === false
        hash[key] = value
      else
        hash[key] = array_or_string_for_javascript(value)
      end
    end
    options_for_javascript(hash)
  end

end
