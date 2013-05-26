module Formy

  class Tabs < Root
    #
    # options:
    #   :class -- class to add to the ul
    #   :id    -- id to add to the ul
    #

    sub_element Tab

    def initialize(options={})
      super(options)
      @opts[:separator] ||= "|"
    end

    def open
      super
      open_group
    end

    def close
      close_group
      super
    end

    protected

    def open_group
      puts "<div style='height:1%'>" # this is to force hasLayout in ie
      puts '<ul class="nav nav-tabs %s" data-toggle="buttons-radio">' % @opts[:class]
    end

    def close_group
      @elements.each {|e| raw_puts e}
      puts "<li></li></ul>"
      puts "</div>"
    end

  end

end
