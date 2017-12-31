# LINKS WITH ICONS
#
# Examples:
#
#  link_to 'settings', me_settings_path, :icon => 'edit'
#
#

module Common::Ui::LinkWithIcon

  #
  # makes a cool link with an icon. if you click the link, some ajax
  # thing happens, and the icon is set to a spinner. The icon is
  # restored when the ajax request completes.
  #
  def link_to_remote(name, options, html_options = {})
    icon = html_options[:icon] || html_options[:button_icon]
    if icon.nil?
      super(name, options, html_options)
    else
      add_icon_class(html_options)
      id = html_options[:id] || format('link%s', rand(1_000_000))
      html_options[:id] ||= id

      # don't bother with spinner for confirm links:
      icon_options = {}
      unless options[:confirm]
	icon_options[:loading] = [spinner_icon_on(icon, id), options[:loading]].combine(';')
	# i am not sure the best way to handle this. we don't want to do :complete for
	# certain icons. For example, checkboxes change the icon after a complete, so
	# replacing the old icon for checkboxes would be a bad idea.
	# the star displays like an on/off checkbox, so don't do a complete in that case either.
	unless icon =~ /check/ or icon =~ /star/
	  icon_options[:complete] = [spinner_icon_off(icon, id), options[:complete]].combine(';')
	end
      end
      link_to_remote_with_confirm(name, options.merge(icon_options), html_options)
    end
  end

  def link_to_function(name, *args, &block)
    html_options = args.extract_options!.symbolize_keys
    if html_options
      add_icon_class(html_options)
      args << html_options
    end
    super(name, *args, &block)
  end

  #
  # support the signature of normal link_to:
  #
  # link_to(name, options = {}, html_options = nil)
  # link_to(options = {}, html_options = nil) do
  #   name
  # end
  #
  def link_to(*args, &block)
      html_options = if block
                       args[1]
                     else
                       args[2]
                     end
      add_icon_class(html_options) if html_options
      super(*args, &block)
  end

  alias_method :link_to_function_with_icon, :link_to_function

end

module Common::Ui::LinkToIconHelper

  include PrototypeHelper
  prepend Common::Ui::LinkWithIcon

  ##
  ## LINK TO ICON
  ## (no text, just icon)
  ##

  def link_to_remote_icon(icon, options = {}, html_options = {})
    html_options[:button_icon] = icon
    link_to_remote('', options, html_options)
  end

  def link_to_function_icon(icon, function, html_options = {})
    html_options[:button_icon] = icon
    link_to_function('', function, html_options)
  end

  def link_to_icon(icon, options, html_options = {})
    html_options[:button_icon] = icon
    link_to '', options, html_options
  end

  private

  #
  # two kinds of icon classes: 'icon' and 'small_icon_button'.
  #
  # the latter is used when there is no text.
  #
  def add_icon_class(html_options)
    if icon = html_options.delete(:icon)
      html_options[:class] = ['icon', "#{icon}_16", html_options[:class]].combine
    elsif icon = html_options.delete(:button_icon)
      html_options[:class] = ['small_icon_button', "#{icon}_16", html_options[:class]].combine
    end
  end
end
