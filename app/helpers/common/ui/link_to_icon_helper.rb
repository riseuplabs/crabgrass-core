#
# LINKS WITH ICONS
#
# Examples:
#
#  link_to 'settings', me_settings_path, :icon => 'edit'
#
#
module Common::Ui::LinkToIconHelper

  def self.included(base)
    unless ActionView::Base.method_defined? :link_to_with_icon
      ActionView::Base.send(:include, ActionViewExtension)
    end
  end

  module ActionViewExtension

    include PrototypeHelper

    def self.included(base)
      base.class_eval do
        alias_method_chain :link_to, :icon
        alias_method_chain :link_to_remote, :icon
        alias_method_chain :link_to_function, :icon
      end
    end

    #
    # makes a cool link with an icon. if you click the link, some ajax
    # thing happens, and the icon is set to a spinner. The icon is
    # restored when the ajax request completes.
    #
    def link_to_remote_with_icon(name, options, html_options={})
      icon = html_options[:icon] || html_options[:button_icon]
      if icon.nil?
        link_to_remote_without_icon(name, options, html_options)
      else
        add_icon_class(html_options)
        id = html_options[:id] || 'link%s'%rand(1000000)
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

        ## FIXME: no idea why this isn't html_safe? anymore.
        link_to_remote_without_icon(name, options.merge(icon_options), html_options).html_safe
      end
    end

    def link_to_function_with_icon(name, *args, &block)
      html_options = args.extract_options!.symbolize_keys
      if html_options
        add_icon_class(html_options)
        args << html_options
      end
      ## FIXME: no idea why this isn't html_safe? anymore.
      link_to_function_without_icon(name, *args, &block).html_safe
    end

    #
    # support the signature of normal link_to:
    #
    # link_to(name, options = {}, html_options = nil)
    # link_to(options = {}, html_options = nil) do
    #   name
    # end
    #
    def link_to_with_icon(*args, &block)
      if block
        html_options = args[1]
      else
        html_options = args[2]
      end
      if html_options
        add_icon_class(html_options)
      end
      ## FIXME: no idea why this isn't html_safe? anymore.
      link_to_without_icon(*args, &block).html_safe
    end

    ##
    ## LINK TO ICON
    ## (no text, just icon)
    ##

    def link_to_remote_icon(icon, options={}, html_options={})
      html_options[:button_icon] = icon
      link_to_remote_with_icon('', options, html_options)
    end

    def link_to_function_icon(icon, function, html_options={})
      html_options[:button_icon] = icon
      link_to_function_with_icon('', function, html_options)
    end

    def link_to_icon(icon, options, html_options={})
      html_options[:button_icon] = icon
      link_to_with_icon '', options, html_options
    end

    private

    #
    # two kinds of icon classes: 'icon' and 'small_icon_button'.
    #
    # the latter is used when there is no text.
    #
    def add_icon_class(html_options)
      if icon = html_options.delete(:icon)
        html_options[:class] = ["icon", "#{icon}_16", html_options[:class]].combine
      elsif icon = html_options.delete(:button_icon)
        html_options[:class] = ["small_icon_button", "#{icon}_16", html_options[:class]].combine
      end
    end

  end
end

