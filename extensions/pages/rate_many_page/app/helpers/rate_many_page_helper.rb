module RateManyPageHelper
  @@map = {
    2 => 'good', 'good' => 2,
    1 => 'ok', 'ok' => 1,
    0 => 'none', 'none' =>  0,
    -1 => 'bad', 'bad'  => -1,
    -2 => 'no', 'no' => -2
  }
  def map(value)
    @@map[value]
  end

  # value a string, one of 'good', 'ok', 'bad', 'no'
  def button_row(possible, vote, value)
    button = radio_button_tag(
      "vote[#{possible.id}]",   # name
      map(value),               # value
      value == map(vote.value), # checked?
      disabled: !current_user.may?(:edit, @page),
      onclick: remote_function(
        url: rate_many_possible_url(possible, page_id: @page, value: map(value)),
        method: :put,
        loading: show_spinner(format('possible_%s', possible.id))
      )
    )

    render 'rate_many_page/button', button: button,
                                    value: value,
                                    id: "vote_#{possible.id}_#{map(value)}"
  end
end
