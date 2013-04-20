#
# Abstract superclass for forms
#

module Formy
  class BaseForm < Root

    def label(value=nil)
      if value
        @elements << indent('<div class="legend %s">%s</div>' % [first(:legend), value])
      end
    end

    def button(value=nil)
      @buttons ||= []
      if value
        @buttons << value
      end
    end

    def open(css_class=nil)
      super()
      if css_class
        puts '<fieldset class="%s">' % css_class
      else
        puts '<fieldset>'
      end
    end

    def close
      @elements.each {|e| raw_puts e}
      if @buttons
        puts_push '<div class="form-actions">'
        #if @control_group
        #  puts_push '<div class="control-group">'
        #  puts_push '<div class="controls">'
        #end
        @buttons.each do |button|
          puts button
        end
        #if @control_group
        #  puts_pop '</div>'
        #  puts_pop '</div>'
        #end
        puts_pop '</div>'
      end
      puts "</fieldset>"
      super
    end

    class Row < Element
      element_attr :info, :label, :input
      def open
        super
      end
      def close
        super
      end
    end

  end
end
