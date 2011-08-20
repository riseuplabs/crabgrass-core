##
## Theme Helper -- a mixin for ActionView::Base
##

module Crabgrass::Theme::Helper
  def theme_render(value)
    return unless value
    if value.is_a? Proc
      self.instance_eval &value
    elsif value.is_a? Hash
      render value
    elsif value.is_a? String
      value
    end
  end

  # takes a border string, like '2px solid green'
  # and returns 2
  def border_width(string)
    string = string.to_s
    if string =~ /px/
      string.split(' ').first.to_i
    else
      0
    end
  end

end

