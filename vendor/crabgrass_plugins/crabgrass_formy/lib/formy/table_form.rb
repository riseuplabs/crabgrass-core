module Formy

  class TableForm < Root
    element_attr :buttons

    def title(value)
      puts "<tr class='#{TITLE_CLASS} #{first}'><td colspan='2'>#{value}</td></tr>"
    end

    def label(value="&nbsp;".html_safe)
      @elements << indent("<tr class='#{LABEL_CLASS} #{first}'><td colspan='2'>#{value}</td></tr>")
    end

    def spacer
      @elements << indent("<tr class='#{SPACER_CLASS}'><td colspan='2'><div></div></td></tr>")
    end

    def heading(text)
      @elements << indent("<tr class='#{first}'><td colspan='2' class='#{HEADING_CLASS}'><h2>#{text}</h2></td></tr>")
    end

    def hidden(text)
      @elements << indent("<tr style='display:none'><td>#{text}</td></tr>")
    end

    def raw(text)
      @elements << indent("<tr><td colspan='2'>#{text}</td></tr>")
    end

    def open
      super
      puts "<table class='#{FORM_CLASS}'>"
      title(@opts[:title]) if @opts[:title]
    end

    def close
      @elements.each {|e| raw_puts e}
      if @buttons
        puts "<tr><td colspan='2' class='#{BUTTONS_CLASS}'>#{@buttons}</td></tr>"
      end
      puts '</table>'
      super
    end

#    class Section < Element
#      sub_element :row
#      def label(value)
#        puts "label(#{value})<br>"
#      end
#    end

    class Row < Element
      element_attr :info, :label, :label_for, :input, :id, :style, :classes

      def open
        super
        @opts[:style] ||= :hang
      end

      def close
        @input ||= @elements.first.to_s
        @classes = [@classes, @opts[:class]].combine
        if @opts[:style] == :hang
          @label ||= '&nbsp;'.html_safe
          labelspan = inputspan = 1
          #labelspan = 2 if @label and not @input
          #inputspan = 2 if @input and not @label
          puts '<tr class="row %s %s" id="%s" style="%s">' % [parent.first, @classes, @id, @style]
          puts '<td colspan="%s" class="%s"><label for="%s">%s</label></td>' % [labelspan, LABEL_CLASS, @label_for, @label]
          if @input
            puts '<td colspan="%s" class="%s">' % [inputspan, INPUT_CLASS]
            puts '<div class="%s">%s</div>' % [INPUT_CLASS, @input]
            if @info
              puts '<div class="%s">%s</div>' % [INFO_CLASS, @info]
            end
            puts '</td>'
          end
          puts '</tr>'
        elsif @opts[:style] == :stack
          if @label
            puts '<tr><td class="%s">%s</td></tr>' % [LABEL_CLASS, @label]
          end
          puts '<tr class="%s">' % @opts[:class]
          puts '<td class="%s">%s</td>' % [INPUT_CLASS, @input]
          puts '<td class="%s">%s</td>' % [INFO_CLASS, @info]
          puts '</tr>'
        end
        super
      end

      class Checkboxes < Element
        def open
          super
          puts "<table>"
        end

        def close
          puts @elements.join("\n")
          puts "</table>"
          super
        end

        class Checkbox < Element
          element_attr :label, :input, :info

          def open
            super
          end

          def close
            id = @input.match(/id=["'](.*?)["']/).to_a[1] if @input
            label = content_tag :label, @label, :for => id
            puts tag(:tr, content_tag(:td, @input) + content_tag(:td, label))
            if @info
              puts tag(:tr, content_tag(:td, '&nbsp;'.html_safe) + content_tag(:td, @info, :class => INFO_CLASS))
            end
            super
          end
        end
        sub_element TableForm::Row::Checkboxes::Checkbox
      end
      sub_element TableForm::Row::Checkboxes
    end
    sub_element TableForm::Row

  end
end
