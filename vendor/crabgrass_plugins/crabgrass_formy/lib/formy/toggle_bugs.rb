module Formy

  class ToggleBugs < Tabs

    class Bug < Formy::Tabs::Tab
      protected

      def put_item
        selected = 'active' if @selected
        first = 'first' if @options[:index] == 0
        @class = [@class, 'btn', selected, first].compact.join(' ')
        puts build_link
      end
    end


    sub_element ToggleBugs::Bug

    def open_group
      # the data-toggle is bootstrap js standart - we'll start using
      # it once we switched to jquery
      puts '<div class="btn-group" data-toggle="buttons-radio">'
    end

    def close_group
      @elements.each {|e| raw_puts e}
      puts '</div>'
    end
  end
end


