
module Formy
  class SimpleForm < Root

    def open
      super
      puts '<div class="simple_form">'
    end

    def close
      @elements.each {|e| raw_puts e}
      puts "</div>"
      super
    end

    class Row < Element
      element_attr :id, :info, :label, :input

      def open
        super
      end

      def close
        if @label.is_a? Array
          @label, @label_for = @label
        end
        html = []
        html << '<div class="row" id="%s">' % @id
        html << '<label for="%s">%s</label>' % [@label_for, @label]
        html << @input
        html << '</div>'
        puts html.join
        super
      end
    end

    class Buttons < Element

      def button(button_html)
        @buttons ||= []
        @buttons << button_html
      end

      def open
        super
      end
      def close
        puts content_tag(:div, @buttons.join("\n"), :class => 'form_buttons')
        super
      end

    end


    sub_element Row
    sub_element Buttons

  end
end
