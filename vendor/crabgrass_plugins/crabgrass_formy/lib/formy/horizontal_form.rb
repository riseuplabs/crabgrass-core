#
# A form based on bootstrap's horizontal form.
# See http://twitter.github.com/bootstrap/base-css.html#forms
#
# For example
#
# <form class="form-horizontal">
#   <div class="control-group">
#     <label class="control-label" for="inputEmail">Email</label>
#     <div class="controls">
#       <input type="text" id="inputEmail" placeholder="Email">
#     </div>
#   </div>
#   <div class="control-group">
#     <label class="control-label" for="inputPassword">Password</label>
#     <div class="controls">
#       <input type="password" id="inputPassword" placeholder="Password">
#     </div>
#   </div>
#   <div class="control-group">
#     <div class="controls">
#       <label class="checkbox">
#         <input type="checkbox"> Remember me
#       </label>
#       <button type="submit" class="btn">Sign in</button>
#     </div>
#   </div>
# </form>
#

module Formy

  class HorizontalForm < BaseForm

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
      @control_group = true
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
        @input ||= @elements.first.to_s
        if @label.is_a? Array
          @label, @label_for = @label
        else
          @label ||= '&nbsp;'.html_safe
        end

        puts '<div class="control-group %s %s" id="%s" style="%s">' % [parent.first(:row), @classes, @id, @style]
        puts content_tag(:label, @label, :for => @label_for, :class => 'control-label')
        puts '<div class="controls">'
        if @input
            puts @input
            if @info
              puts content_tag(:p, @info.html_safe, :class => 'help-block')
            end
          end
        puts '</div>'
        puts '</div>'
        super
      end


      # <div class="controls">
      #   <label class="checkbox">
      #     <input type="checkbox" name="optionsCheckboxList1" value="option1">
      #     Option one is this and that—be sure to include why it's great
      #   </label>
      #   <label class="checkbox">
      #     <input type="checkbox" name="optionsCheckboxList2" value="option2">
      #     Option two can also be checked and included in form results
      #   </label>
      #   <label class="checkbox">
      #     <input type="checkbox" name="optionsCheckboxList3" value="option3">
      #     Option three can—yes, you guessed it—also be checked and included in form results
      #   </label>
      #   <p class="help-block"><strong>Note:</strong> Labels surround all the options for much larger click areas and a more usable form.</p>
      # </div>
      class Checkboxes < Element
        def open
          super
        end

        def close
          puts @elements.join("\n")
          super
        end

        class Checkbox < Element
          element_attr :label, :input, :info
          def open
            super
          end

          def close
            puts content_tag(:label, :class => 'checkbox') do
               @input + "\n" + @label
            end
            if @info
              puts content_tag(:p, @info.html_safe, :class => 'help-block')
            end
            super
          end
        end
        sub_element HorizontalForm::Row::Checkboxes::Checkbox

      end
      sub_element HorizontalForm::Row::Checkboxes

    end
    sub_element HorizontalForm::Row

  end
end

##
## EXAMPLE
##

# <fieldset class="form-horizontal">
#   <legend>Controls Bootstrap supports</legend>
#   <div class="control-group">
#     <label class="control-label" for="input01">Text input</label>
#     <div class="controls">
#       <input type="text" class="input-xlarge" id="input01">
#       <p class="help-block">In addition to freeform text, any HTML5 text-based input appears like so.</p>
#     </div>
#   </div>
#   <div class="control-group">
#     <label class="control-label" for="optionsCheckbox">Checkbox</label>
#     <div class="controls">
#       <label class="checkbox">
#         <input type="checkbox" id="optionsCheckbox" value="option1">
#         Option one is this and that—be sure to include why it's great
#       </label>
#     </div>
#   </div>
#   <div class="control-group">
#     <label class="control-label" for="select01">Select list</label>
#     <div class="controls">
#       <select id="select01">
#         <option>something</option>
#         <option>2</option>
#         <option>3</option>
#         <option>4</option>
#         <option>5</option>
#       </select>
#     </div>
#   </div>
#   <div class="control-group">
#     <label class="control-label" for="multiSelect">Multicon-select</label>
#     <div class="controls">
#       <select multiple="multiple" id="multiSelect">
#         <option>1</option>
#         <option>2</option>
#         <option>3</option>
#         <option>4</option>
#         <option>5</option>
#       </select>
#     </div>
#   </div>
#   <div class="control-group">
#     <label class="control-label" for="fileInput">File input</label>
#     <div class="controls">
#       <input class="input-file" id="fileInput" type="file">
#     </div>
#   </div>
#   <div class="control-group">
#     <label class="control-label" for="textarea">Textarea</label>
#     <div class="controls">
#       <textarea class="input-xlarge" id="textarea" rows="3"></textarea>
#     </div>
#   </div>
#   <div class="form-actions">
#     <button type="submit" class="btn btn-primary">Save changes</button>
#     <button class="btn">Cancel</button>
#   </div>
# </fieldset>
