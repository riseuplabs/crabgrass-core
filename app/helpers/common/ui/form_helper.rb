##
## globally useful helpers for form elements.
##

module Common::Ui::FormHelper
  #
  # add a row of radio buttons with labels
  # using a similar api to select and select_tag
  #
  # choices: array of choices in the form [[label, id],[label, id]]
  #
  # options:
  #  * :selected  - id of the selected option(s)
  #                 false to select none
  #   all others will be handed over to the radio_button_tag.
  #
  def inline_radio_buttons(name, choices, options = {})
    selected = options.delete(:selected)
    selected = choices.first[1] if selected.nil?
    render partial: 'ui/form/inline_radio_button',
           collection: choices,
           locals: { name: name, selected: selected, options: options }
  end
end
