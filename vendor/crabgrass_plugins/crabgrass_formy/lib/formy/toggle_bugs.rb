module Formy

  class ToggleBugs < Tabs

    class Bug < Formy::Tab
      protected

      def put_item
        first = 'first' if @opts[:index] == 0
        @class = [@class, 'btn', first].compact.join(' ')
        puts build_link
      end
    end

    sub_element ToggleBugs::Bug

    def open_group
      puts '<div class="btn-group" data-toggle="buttons-radio">'
    end

    def close_group
      @elements.each {|e| raw_puts e}
      puts '</div>'
    end
  end
end


