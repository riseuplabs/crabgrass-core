#
# Here lives little miscellaneous reusable UI elements.
# This is like FormTagHelper, but they might not be forms.
#
# We call the gizmos. 
#
# Current gizmos:
# * toggle_bug
# * spinner_checkbox
#

module Ui::GizmoHelper


  #
  # a toggle bug is a set of grouped links, only one of which may be active at a
  # a time.
  #
  # links is an array of hashes, each with these keys:
  #
  #   :label
  #   :url
  #   :active
  # 
  def toggle_bug_links(*links)
    content_tag(:ul, :class => 'toggle_bug') do 
      links.collect do |link|
        classes = [
          link[:active] ? 'active' : '',
          link == links.first ? 'first' : '',
          link == links.last ? 'last' : ''
        ].combine
        content_tag(:li, :class => classes) do
          link_to(link[:label], link[:url])
        end
      end.join
    end
  end

  # 
  # A checkbox used for ajax or functions. The checkbox turns into a spinner
  # until the action is complete.
  # 
  # options:
  #  checked: true or false
  #
  # args:
  #  name, label, url
  #
#  def spinbox_tag(name, label, url, options = {})
#    li_id        = options[:id] || "#{name}_spinbox_li"
#    checkbox_id  = "#{name}_spinbox_checkbox"
#    checked      = options[:checked]

#    onclick_function = queued_remote_function(
#      :url => url,
#      :before  => checkbox_spin(li_id, checkbox_id),
#      :complete => checkbox_unspin(li_id, checkbox_id),
#      :with => options[:with]
#    )

#    content_tag(:li, :class => "spinbox small_icon #{li_id}", :id => li_id) do
#      check_box_tag(checkbox_id, '1', checked, :onclick => onclick_function, :class => checkbox_id) +
#      link_to_function(label, "$('#{checkbox_id}').click()")
#    end
#  end

#  def checkbox_spin(li_class, checkbox_class)
#    set_style(".#{li_class}", "background-image: url(/images/spinner.gif)") + 
#    set_style(".#{checkbox_class}", "display:none")
#  end

#  def checkbox_unspin(li_class, checkbox_class)
#    clear_style(".#{li_class}") + clear_style(".#{checkbox_class}")
#  end

end

