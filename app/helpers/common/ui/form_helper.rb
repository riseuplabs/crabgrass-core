##
## globally useful helpers for form elements.
##

module Common::Ui::FormHelper

  def option_empty(label='')
    %(<option value=''>#{label}</option>)
  end

  # DROP DOWN LIST
  #
  # use this as:
  #
  # drop_down("Title", {"Option 1" => some_place_path, "Option 2" => "js: alert('hello')"}, optionally_index_for_selected_option)
  #
  # <label for="select_id">Title</label>
  # <select id="select_id">
  #   <option value="/some/place">Option 1</option>
  #   <option value="alert('hello')">Option 2</option>
  # </select>
  #
  # Actions happen on the onchange event
  #
  def drop_down(select_title, items, selected_index = 0)

    select_id = "select_#{select_title.gsub(/[^a-zA-Z]+/, '')}"

    text_label = content_tag(:label, I18n.t(:view_label), :for => select_id) if !select_title.nil? && !select_title.blank?

    current_index = 0
    options = items.map do |title, perform|
      selected = selected_index == current_index ? {:selected => "selected"} : {}
      current_index += 1
      perform = url_for(perform) if perform.is_a?(Hash)
      option_id = "option_#{title.gsub(/[^a-zA-Z]+/, '')}"
      value = drop_down_action(perform)
      content_tag :option, title, {:value => value, :id => option_id}.merge(selected)
    end.join("\n")

    content_tag(:div, text_label + select_tag(select_id, options, :onchange => "javascript: eval(this.options[this.selectedIndex].value)"), :id => "pages_view")
  end

  def drop_down_action(perform)
    if perform.match(/^js\:/)
      perform.gsub(/^js\:/, '')
    else
      "window.location = '#{perform}';"
    end
  end

  #
  # add some radio buttons, using a similar api to select and select_tag
  #
  # choices: array of choices in the form [[label, id],[label, id]]
  #
  # options:
  #  * :separator - will be used to separate the buttons
  #  * :selected - id of the selected button
  #  ... all others will be handed over to the radio_button_tag.
  #
  def radio_buttons_tag(name, choices, options={})
    join = options.delete(:separator) || ' '
    selected = options.delete(:selected) || choices.first[1]
    html = []
    choices.each do |label, id|
      checked = selected == id
      html << radio_button_tag(name, id, checked, options) +
              label_tag("%s_%s" % [name, id], label)
    end
    html.join(join)
  end

  #
  # Wraps arguments in a div with class 'input-append'. This is a bootstrap css thing:
  #
  # <div class="input-append">
  #   <input class="span2" id="appendedInputButton" type="text">
  #   <button class="btn" type="button">Go!</button>
  # </div>
  #
  # Warning: input args are tags as html_safe.
  #
  def input_append(*args)
    content_tag :div, args.join("\n").html_safe, :class => 'input-append'
  end

end
