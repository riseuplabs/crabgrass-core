# LINKS WITH ICONS
#
# Examples:
#
#  link_to 'settings', me_settings_path, :icon => 'edit'
#
#

module Common::Ui::LinkToIconHelper

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
      m = ActionView::Helpers::UrlHelper.instance_method(:link_to).bind(self)
      # FIXME: we do not want to permit! everything
      args[0] = args[0].permit!.to_h if (args[0]&.class == ActionController::Parameters)
      args[1] = args[1].permit!.to_h if (args[1]&.class == ActionController::Parameters)
      m.call(*args, &block)
  end

  alias_method :link_to_function_with_icon, :link_to_function


  ##
  ## LINK TO ICON
  ## (no text, just icon)
  ##

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
