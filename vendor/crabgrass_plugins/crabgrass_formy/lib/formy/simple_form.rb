#
# A simple stacked form, following bootstrap markup.
#
# http://twitter.github.com/bootstrap/base-css.html#forms
#
# For example:
#
# <form>
#   <fieldset>
#     <legend>Legend</legend>
#     <label>Label name</label>
#     <input type="text" placeholder="Type something…">
#     <span class="help-block">Example block-level help text here.</span>
#     <label class="checkbox">
#       <input type="checkbox"> Check me out
#     </label>
#     <button type="submit" class="btn">Submit</button>
#   </fieldset>
# </form>
#

module Formy
  class SimpleForm < BaseForm
    class Row < BaseForm::Row
      def close
        if @label.is_a? Array
          @label, @label_for = @label
        end
        html = []
        if @input && @input =~ /type=.checkbox./
          html << '<label class="checkbox">'
          html << [@input, ' ', @label].join
          html << '</label>'
          if @info
            html << '<span class="checkbox help-block">%s</span>' % @info
          end
        else
          html << '<label for="%s">%s</label>' % [@label_for, @label]
          html << @input
          if @info
            html << '<span class="help-block">%s</span>' % @info
          end
        end
        puts html
        super
      end
    end

    sub_element Row
  end
end
