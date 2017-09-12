#
# Abstract superclass for forms
#

module Formy
  class BaseForm < Root
    def label(value = nil)
      if value
        @elements << indent(format('<div class="legend %s">%s</div>', first(:legend), value))
      end
    end

    def button(value = nil)
      @buttons ||= []
      @buttons << value if value
    end

    def open(css_class = nil)
      super()
      if css_class
        puts_push format('<fieldset class="%s">', css_class)
      else
        puts_push '<fieldset>'
      end
    end

    def close
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
