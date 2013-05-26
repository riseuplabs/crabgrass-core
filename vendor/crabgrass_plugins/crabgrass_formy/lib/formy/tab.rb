module Formy
  class Tab < Element
    #
    # Tab attributes:
    #
    # required:
    #   link | (label & (link|url|show_tab|function))
    #
    #   link     -- the a tag to put as the tab label.
    #   url      -- the url to link the tab to
    #   show_tab -- the dom_id of the div to show when the panel is clicked
    #   function -- javascript to get called when the tab is clicked. may be used alone or
    #               in conjunction with show_tab or url (but not compatible with 'link' option)
    #
    #   if show_tab is set to an dom id that ends in '_panel', then special things happen:
    #
    #    (1) the link is given an id with _panel replaced by _link
    #    (2) the window.location.hash is set by removing '_panel'
    #
    # optional:
    #   selected / active -- tab is active if true
    #   icon -- name of an icon to give the tab
    #   id -- dom id for the tab link
    #   style -- custom css
    #   class -- custom css class
    #   options -- hash of options to pass to link_to
    #
    # show_tab modifiers:
    #   hash -- overide default location.hash that is activated when this tab is activated
    #   default -- if true, this is the default tab that gets loaded.
    #

    element_attr :label, :link, :show_tab, :url, :function, :selected, :icon, :id,
      :style, :class, :hash, :default, :active, :options

    def close
      put_item
      super
    end

    protected

    def put_item
      selected = 'active' if @selected || @active
      first = 'first' if @opts[:index] == 0
      li_class = [selected, first, @class].compact.join(' ')
      puts content_tag(:li, build_link, :class => li_class)
    end

    def build_link
      if @link
        @link
      else
        # sadly, the link_to stuff that would be good to include here is not
        # present until a later version of rails.
        #if @url
        #  link_to(@label, @url, link_options) + postfix_for_link
        #else
          content_tag(:a, @label, link_options) + postfix_for_link
        #end
      end
    end

    def link_options
      @options ||= {}
      if @show_tab =~ /_panel$/
         @id = @show_tab.sub(/_panel$/, '_link')
      end
      css_class = [
        @class,
        ("icon #{@icon}_16" if @icon),
        ("active" if @selected || @active),
        @options.delete(:class)
      ].compact.join(' ')
      options = {
          :class => css_class,
          :style => @style,
          :id => @id,
          :onclick => @function
      }
      if @url
        options[:href] = @url
      elsif @show_tab
        options[:onclick] = onclick_for_show_tab
      elsif @function
        options[:href] = "#"
      end
      return options.merge(@options)
    end

    def onclick_for_show_tab
      if @show_tab =~ /_panel$/
        @hash ||= @show_tab.sub(/_panel$/, '').gsub('_','-')
        onclick = "showTab(this, $('%s'), '%s');" % [@show_tab, @hash]
      else
        onclick = "showTab(this, $('%s'));" % @show_tab
      end
      if @function
        @function += ';' unless @function[-1].chr == ';'
        onclick = @function + onclick
      end
      return onclick.html_safe
    end

    def postfix_for_link
      @show_tab && @default ?
        javascript_tag('defaultHash = "%s"' % @hash) :
        ""
    end
  end
end
