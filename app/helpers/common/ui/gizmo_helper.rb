#
# Here lives little miscellaneous reusable UI elements.
#
# We call them gizmos.
#
# Current gizmos:
# * toggle_bug
# * spinbox
#

module Common::Ui::GizmoHelper


  ##
  ## TOGGLE_BUG
  ##

  #
  # a toggle bug is a set of grouped links, only one of which may be active at a
  # a time.
  #
  # links is an array of hashes, each with these keys:
  #
  #   :label  -- the text of the link
  #   :active -- link is shown hilighted if true.
  #
  #   and one of:
  #   (1) :url    -- creates a normal link_to
  #   (2) :remote -- creates a link_to_remote
  #   (3) :function -- creates a link_to_function
  #
  def toggle_bug_links(*links)
    content_tag(:ul, :class => 'toggle_bug') do
      links.collect do |link|
        classes = [
          link[:active] ? 'active' : '',
          link == links.first ? 'first' : '',
          link == links.last ? 'last' : ''
        ].combine
        content_tag(:li, :class => classes, :id => link[:id]) do
          if link[:remote]
            link_to_remote(link[:label], link[:remote])
          elsif link[:function]
            link_to_function(link[:label], link[:function])
          else
            link_to(link[:label], link[:url])
          end
        end
      end.join
    end
  end

  # used for javascript toggle bugs
  def deactivate_toggle_bugs
    "$$('.toggle_bug li').invoke('removeClassName', 'active');"
  end
  def activate_toggle_bug(id)
    deactivate_toggle_bugs + "$('#{id}').addClassName('active');"
  end

  ##
  ## SPINBOX
  ##

  #
  #
  # A checkbox used for ajax or functions. The checkbox turns into a spinner
  # until the action is complete. The requests are queued, so that you can
  # click a lot of spinboxes all at once -- there will not be any race condition.
  #
  # Options:
  #
  #  :label, :checked, :with, :method, :success, :tag
  #
  # TODO: make this actually work with functions, not just remote ajax calls.
  #
  # for the :tag option, it defaults to li, but you might instead want a span, for example
  # Requires:
  #  - link_to_function_with_icon
  #  - queued_remote_function
  #
  def spinbox_tag(name, url, options = {})
    icon = options[:checked] ? 'check_on' : 'check_off'
    options[:tag] ||= :li
    options = options.merge(:url => url, :id => "#{name}_spinbox", :icon => icon)

    function = queued_remote_function(spinbox_function_options(options))
    content_tag(options[:tag]) do
      spinbox_link_to_function(function, options)
    end
  end

  private

  def spinbox_function_options(options)
    options.merge!(
      :before  => spinner_icon_on(options[:icon], options[:id])
      # no :complete option, because in cases where this is used, so
      # far we end up replacing the spinbox itself. but maybe this could be
      # necessary someday:
      # :complete => spinner_icon_off(options[:icon], options[:id])
    )
    options.slice(:url, :before, :with, :method, :success)
  end

  def spinbox_link_to_function(function, options)
    if options[:label].blank?
      link_to_function_icon(options[:icon], function, options.slice(:url, :id))
    else
      link_to_function_with_icon(options[:label], function, options.slice(:url, :id, :icon))
    end
  end

end

