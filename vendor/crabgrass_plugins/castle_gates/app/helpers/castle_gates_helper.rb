#
# This helper requires that the method 'key_holder_path(holder_code)' be defined.
# This method should return a path to a controller that responds to 'update'.
# For example:
#
#   def key_holder_path(id, *args)
#     me_permission_path(id, *args)
#   end
#   helper_method :key_holder_path
#
# Where 'id' is the holder_code
#

module CastleGatesHelper

  #
  # display checkboxes for a castle gate, one checkbox for each possible holder.
  #
  def castle_gate_tag(castle, gate, holders, options = {})
    content_tag :ul do
      holders.collect do |holder|
        castle_gate_checkbox(castle, gate, holder, options)
      end.join.html_safe
    end
  end

  def castle_gate_checkbox(castle, gate, holder, options = {})
    name = "#{gate}_#{holder.to_s}"
    options = options.dup
    options[:label] ||= holder.definition.label.t
    options[:method] = 'put'
    options[:checked] = castle.access?(holder => gate)
    url  = key_holder_path(holder.code, 'gate' => gate, 'new_state' => options[:checked] ? 'closed' : 'open')
    spinbox_tag(name, url, options)
  end

end
