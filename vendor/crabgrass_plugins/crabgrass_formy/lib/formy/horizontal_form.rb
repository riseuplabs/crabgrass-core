#
# A form based on bootstrap's horizontal form.
# http://getbootstrap.com/css/#forms-horizontal
#
# For example
#
# <formset class="form-horizontal">
#   <div class="form-group">
#     <label for="inputEmail3" class="col-sm-2 control-label">Email</label>
#     <div class="col-sm-10">
#       <input type="email" class="form-control" id="inputEmail3" placeholder="Email">
#     </div>
#   </div>
#   <div class="form-group">
#     <label for="inputPassword3" class="col-sm-2 control-label">Password</label>
#     <div class="col-sm-10">
#       <input type="password" class="form-control" id="inputPassword3" placeholder="Password">
#     </div>
#   </div>
#   <div class="form-group">
#     <div class="col-sm-offset-2 col-sm-10">
#       <div class="checkbox">
#         <label>
#           <input type="checkbox"> Remember me
#         </label>
#       </div>
#     </div>
#   </div>
#   <div class="form-group">
#     <div class="col-sm-offset-2 col-sm-10">
#       <button type="submit" class="btn btn-default">Sign in</button>
#     </div>
#   </div>
# </formset>
#

module Formy
  class HorizontalForm < BaseForm
    LEFT_COL = 'col-sm-3'.freeze
    LEFT_SPACE = 'col-sm-offset-3'.freeze
    RIGHT_COL = 'col-sm-9'.freeze

    def spacer
      #  @elements << indent("<div class='spacer'></div>")
    end

    def heading(text)
      #  @elements << indent("<h2>#{text}</h2>")
    end

    def hidden(text)
      @elements << indent("<div style='display:none'>#{text}</div>")
    end

    def raw(text)
      @elements << indent("<div>#{text}</div>")
    end

    def open
      super('form-horizontal')
    end

    def close
      @elements.each { |e| raw_puts e }
      if @buttons
        puts_push '<div class="form-group">'
        puts_push format('<div class="%s %s">', LEFT_SPACE, RIGHT_COL)
        @buttons.each do |button|
          puts button
        end
        puts_pop '</div>'
        puts_pop '</div>'
      end
      puts_pop '</fieldset>'
      super
    end

    class Row < Element
      element_attr :info, :label, :label_for, :input, :id, :style, :classes

      def open
        super
        @opts[:style] ||= :hang
      end

      # <div class="control-group">
      #   <label class="control-label" for="input01">Text input</label>
      #   <div class="controls">
      #     <input type="text" class="input-xlarge" id="input01">
      #     <p class="help-block">In addition to freeform text, any HTML5 text-based input appears like so.</p>
      #   </div>
      # </div>
      def close
        if @label.is_a? Array
          @label, @label_for = @label
        else
          @label ||= '&nbsp;'.html_safe
         end

        puts_push format('<div class="form-group %s" id="%s" style="%s">', @classes, @id, @style)
        puts content_tag(:label, @label, for: @label_for, class: format('control-label %s', LEFT_COL))
        puts_push format('<div class="%s">', RIGHT_COL)
        if @input
          puts @input
          puts content_tag(:div, @info.html_safe, class: 'help-block') if @info
          end
        puts_pop '</div>'
        puts_pop '</div>'
        super
      end

      # <div class="checkbox">
      #   <label>
      #     <input type="checkbox" value="">
      #     Option one is this and that&mdash;be sure to include why it's great
      #   </label>
      # </div>
      # class Checkboxes < Element
      #   def open
      #     super
      #   end

      #   def close
      #     puts @elements.join("\n")
      #     super
      #   end

      #   class Checkbox < Element
      #     element_attr :label, :input, :info
      #     def open
      #       super
      #     end

      #     def close
      #       puts content_tag(:label, class: 'checkbox') do
      #          @input + "\n" + @label
      #       end
      #       if @info
      #         puts content_tag(:div, @info.html_safe, class: 'help-block')
      #       end
      #       super
      #     end
      #   end
      #   sub_element HorizontalForm::Row::Checkboxes::Checkbox

      # end
      # sub_element HorizontalForm::Row::Checkboxes
    end
    sub_element HorizontalForm::Row
  end
end
