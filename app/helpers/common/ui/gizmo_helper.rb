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
  #   (2) :remote -- creates a remote link_to
  #   (3) :function -- creates a link_to_function
  #
  # example button group:
  #
  # <div class="btn-group" data-toggle="buttons-radio">
  #  <button class="btn">Left</button>
  #  <button class="btn">Middle</button>
  #  <button class="btn">Right</button>
  # </div>
  #
  def toggle_bug_links(*links)
    content_tag(:div, class: 'btn-group') do
      links.collect do |link|
        link[:class] = [
          'btn',
          'btn-default',
          link[:active] ? 'active' : '',
          link == links.first ? 'first' : '',
          link == links.last ? 'last' : ''
        ].combine
        if link[:remote]
          link[:url] = link[:remote]
          link_to link[:label], link.slice(:url, :method).merge(remote: true), link.slice(:class, :id)
        elsif link[:function]
          link_to_function link[:label], link[:function], link.slice(:class, :id)
        else
          link_to link[:label], link[:url], link.slice(:class, :id)
        end
      end.join.html_safe
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
  #  :label, :checked, :with, :method, :success
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
    options = options.merge(url: url, id: "#{name}_spinbox", icon: icon)

    function = queued_remote_function(spinbox_function_options(options))
    spinbox_link_to_function(function, options)
  end

  private

  def spinbox_function_options(options)
    options[:before] = spinner_icon_on(options[:icon], options[:id])
    options[:condition] = 'isEnabled(this)'
    options.slice(:url, :before, :with, :method, :success, :condition)
  end

  def spinbox_link_to_function(function, options)
    if options[:label].blank?
      link_to_function_icon(options[:icon], function, options.slice(:url, :id, :title, :class))
    else
      link_to_function(options[:label], function, options.slice(:url, :id, :icon, :title, :class))
    end
  end
end
