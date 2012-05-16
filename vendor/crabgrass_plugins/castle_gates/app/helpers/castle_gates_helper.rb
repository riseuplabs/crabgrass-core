#
# This helper requires that the method 'key_holder_path(holder_code)' be defined.
# This method should return a path to a controller that responds to 'update'
# and takes holder_id as params[:id]. The remainder of the params are attributes
# for the key.
#

module CastleGatesHelper

  #
  # display checkboxes for a castle gate, one checkbox for each possible holder.
  #
  def castle_gate_tag(castle, gate, holders, options = {})
    #options[:no_label] = (keys.count == 1)
    content_tag :ul do
      holders.collect do |holder|
        castle_gate_checkbox(castle, gate, holder, options)
      end
    end
  end

  def castle_gate_checkbox(castle, gate, holder, options = {})
    name = "#{gate}_#{holder.id}"
    url  = key_holder_path(holder.code)

    #options[:label] = options.delete(:no_label) ? "" : holder.label.t
    options[:label] = horder.label.t
    options[:method] = 'put'
    options[:checked] = castle.access?(holder => gate)
    options[:with] = "'%s='+'%s'" % [gate, !options[:checked]]

    spinbox_tag(name, url, options)
  end

  # private
  # def checkbox_options(key, lock)
  #   checked = key.opens? lock
  #   options = {:checked => checked,
  #     :with => "'#{lock}=' + '#{!checked}'",
  #     :method => 'put'
  #   }
  # end

end
