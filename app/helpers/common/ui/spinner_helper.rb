module Common::Ui::SpinnerHelper

  ## SPINNER
  ##
  ## spinners are animated gifs that are used to show progress.
  ## see JavascriptHelper for showing and hiding spinners.
  ##

  #
  # returns a spinner tag.
  # If this is in a ujs remote form it will automagically start and stop
  # spinning as the form is submitted.
  #
  # arguments:
  #
  #  id -- unique name of the spinner
  #  options -- hash of optional options
  #
  # options:
  #
  #  :show -- if true, default the spinner to be visible
  #  :align -- override the default vertical alignment. generally, should use the default except in <TD> elements with middle vertical alignment.
  #  :class -- add css classes to the spinner
  #  :spinner -- used a different image for the spinner
  #
  def spinner(id = nil, options = {})
    display = ('display:none;' unless options.delete(:show))
    align = "vertical-align:#{options[:align] || 'middle'}"
    options.reverse_merge! spinner: 'spinner.gif',
                           style: "#{display} #{align};",
                           class: 'spin',
                           id: id && spinner_id(id),
                           alt: ''
    options[:src] = "/images/#{options.delete(:spinner)}"
    tag :img, options
  end

  def text_spinner(text, id, options = {})
    span_options = {
      id: spinner_id(id),
      style: ('display:none;' unless options.delete(:show)),
      class: 'spin'
    }
    content_tag :span, span_options do
      options[:style] = 'vertical-align:baseline'
      spinner(nil, options) + text
    end
  end

  def spinner_id(id)
    if id.is_a? ActiveRecord::Base
      id = dom_id(id, 'spinner')
    else
      "#{id}_spinner"
    end
  end

  def spinner_icon_on(icon, id)
    target = id ? "$('#{id}')" : 'eventTarget(event)'
    "replaceClassName(#{target}, '#{icon}_16', 'spinner_icon')"
  end

  def spinner_icon_off(icon, id)
    target = id ? "$('#{id}')" : 'eventTarget(event)'
    "replaceClassName(#{target}, 'spinner_icon', '#{icon}_16')"
  end

  def big_spinner
    content_tag :div, '', style: 'background: white url(/images/spinner-big.gif) no-repeat 50% 50%; height: 5em;', class: 'spin'
  end
end
