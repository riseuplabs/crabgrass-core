
module Formy
  class ListKey < Root

    def title(value)
     puts "<h2 class='title'>#{value}</h2>"
    end

    def open
      super
      title(@options[:title]) if @options[:title]
      puts '<dl class="list_key">'
    end

    def close
      @elements.each {|e| raw_puts e}
      puts '</dl>'
      super
    end

    class Row < Element
      element_attr :info, :label, :style, :classes

      def open
        super
      end

      def close
        puts '<dt class="%s %s" style="%s">%s </dt>' % \
          [first, @classes, @style, @label]
        puts '<dd class="%s %s" style="%s">%s </dd>' % \
          [first, @classes, @style, @info]
        super
      end
    end

    sub_element Row
  end
end
