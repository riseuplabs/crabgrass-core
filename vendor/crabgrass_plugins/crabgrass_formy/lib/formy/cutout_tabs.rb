module Formy
  class CutoutTabs < Tabs
    class Tab < Formy::Tab
      def initialize(form,opts={})
        super(form, opts)
        @class = 'tab'
      end
    end
    sub_element CutoutTabs::Tab

    protected

    def open_group
      puts '<ul class="cutout-tabs %s" id="%s" data-toggle="buttons-radio">' % [@opts[:class], @opts[:id]]
    end

    def close_group
      @elements.each do |tab|
        raw_puts tab
      end
      puts "<li></li></ul>"
    end
  end
end
