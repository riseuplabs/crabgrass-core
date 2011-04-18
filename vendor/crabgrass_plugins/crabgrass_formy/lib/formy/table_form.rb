module Formy

  class TableForm < Root
    def title(value)
      puts "<tr class='title #{first}'><td colspan='2'>#{value}</td></tr>"
    end

    def label(value="&nbsp;")
      @elements << indent("<tr class='label #{first}'><td colspan='2'>#{value}</td></tr>")
    end

    def spacer
      @elements << indent("<tr class='spacer'><td colspan='2'><div></div></td></tr>")
    end

    def heading(text)
      @elements << indent("<tr class='#{first}'><td colspan='2' class='heading'><h2>#{text}</h2></td></tr>")
    end

    def hidden(text)
      @elements << indent("<tr style='display:none'><td>#{text}</td></tr>")
    end

    def raw(text)
      @elements << indent("<tr><td colspan='2'>#{text}</td></tr>")
    end

    def open
      super
      puts "<table class='form'>"
      title(@options[:title]) if @options[:title]
    end

    def close
      @elements.each {|e| raw_puts e}
      puts "</table>"
      super
    end

    def first
      if @first.nil?
        @first = false
        return 'first'
      end
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
        @options[:style] ||= :hang
      end

      def close
        @input ||= @elements.first.to_s
        if @options[:style] == :hang
          @label ||= '&nbsp;'
          labelspan = inputspan = 1
          #labelspan = 2 if @label and not @input
          #inputspan = 2 if @input and not @label
          puts '<tr class="row %s %s" id="%s" style="%s">' % [parent.first, @classes, @id, @style]
          puts '<td colspan="%s" class="label"><label for="%s">%s</label></td>' % [labelspan, @label_for, @label]
          if @input
            puts '<td colspan="%s" class="input">' % inputspan
            puts '<div class="input">%s</div>' % @input
            if @info
              puts '<div class="info">%s</div>' % @info
            end
            puts '</td>'
          end
          puts '</tr>'
        elsif @options[:style] == :stack
          if @label
            puts '<tr><td class="label">%s</td></tr>' % @label
          end
          puts '<tr class="%s">' % @options[:class]
          puts '<td class="input">%s</td>' % @input
          puts '<td class="info">%s</td>' % @info
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
              puts tag(:tr, content_tag(:td, '&nbsp;') + content_tag(:td, @info, :class => 'info'))
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
