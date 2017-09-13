
module Formy
  class Dictionary < Root
    element_attr :title

    def title(value)
      puts format('<h2 class="title">%s</h2>', value)
    end

    def open
      super
      puts '<div class="dictionary">'
      title(@title) if @title
      puts '<dl>'
    end

    def close
      @elements.each { |e| raw_puts e }
      puts '</dl></div>'
      super
    end

    class Row < Element
      element_attr :info, :label, :icon, :style, :classes

      def open
        super
      end

      def close
        puts format('<dt class="%s %s icon" style="%s">%s</dt>', @classes, (@icon + '_16' if @icon), @style, @label)
        puts format('<dd class="%s icon" style="%s">%s</dd>', @classes, @style, @info)
        super
      end
    end

    sub_element Row
  end
end
