#  Modalbox
#
# Displays a modal dialog box
#

module ModalboxHelper

  ##
  ## USE MODALBOX FOR CONFIRM
  ##

  #
  # calls Modalbox.confirm() if options[:confirm] is set.
  #
  #
  # If cancel is pressed, then nothing happens.
  # If OK is pressed, then the remote function is fired off.
  #
  # While loading, the modalbox spinner is shown. When complete, the modalbox is hidden.
  #
  # This method is only used for the deletion of attachments and galley files
  #
  def link_to_with_confirm(name, options = {}, html_options = {})
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
    end
  end

  #
  # redefines link_to to use Modalbox.confirm() if options[:confirm] is set.
  #
  # If cancel is pressed, then nothing happens.
  # If OK is pressed, then a form submit happens, using the action and method specified.
  #
  def link_to(name, url, html_options = nil)
    if html_options.is_a?(Hash) and html_options[:confirm].present?
      url = url_for(url) if url.is_a?(Hash)
      js = <<-EOJS
      Modalbox.confirm("#{html_options.delete(:confirm)}", {
        method:"#{html_options.delete(:method) || 'post'}",
        action:"#{url}",
        token:"#{form_authenticity_token}",
        title:"#{html_options[:title] || name}",
        ok:"#{html_options.delete(:ok) || I18n.t(:ok_button)}",
        cancel:"#{html_options.delete(:cancel) || I18n.t(:cancel)}"})
      EOJS
      link_to_function name, js, html_options
    else
      super
    end
  end

  #
  # create a link that will open a popup with the content
  # rendered in the given block
  #
  # for example:
  #
  #   link_to_static_modal 'edit', icon: :pencil do
  #     render 'edit_this_thing'
  #
  def link_to_static_modal(label, options)
    raise ArgumentError.new 'Yield content in block' unless block_given?
    html_options = options.slice! :title, :width,
    options[:title] ||= label
    contents = yield
    # ensure there are some tags in the html, otherwise modalbox
    # will not recognize it as html.
    contents = format('<p>%s</p>', contents) unless contents =~ /<.+>/
    function = modalbox_function(contents, options)
    link_to_function_with_icon(label, function, html_options)
  end

  #
  # creates a popup-link using modalbox
  #
  # contents will be loaded from the specified url / url hash.
  #
  # if an icon is specified with options[:icon],
  # then the modalbox is not shown until after its contents are loaded.
  #
  # for example:
  #
  #   link_to_modal 'edit', 'some/popup/action', icon: :pencil
  #
  # options can include both the html options for the link such as
  #   id, data, class
  # aswell as the modalbox options such as
  #  title, width, after_load, ...
  #
  # Theoretically it could include all options to modalbox_function.
  # However we only hand those on that are currently in use
  # because we want to reduce the complexity involved
  # and migrate to an unobstrusive js approach.
  #
  def link_to_modal(label, url, options = {})
    html_options = options.slice! :title, :width,
      :after_load, :after_hide, :complete
    options[:title] ||= label
    contents = url.is_a?(Hash) ? url_for(url) : url
    icon = html_options[:icon]
    if icon.present?
      html_options[:id] ||= format('link%s', rand(1_000_000))
      options.merge! loading: spinner_icon_on(icon, html_options[:id]),
          complete: spinner_icon_off(icon, html_options[:id]),
          showAfterLoading: true
    end
    function = modalbox_function(contents, options)
    link_to_function_with_icon(label, function, html_options)
  end

  # close the modal box
  def close_modal_button(label = nil)
    button_to_function((label == :cancel ? I18n.t(:cancel) : I18n.t(:close_button)), 'Modalbox.hide();', class: 'btn btn-default')
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
