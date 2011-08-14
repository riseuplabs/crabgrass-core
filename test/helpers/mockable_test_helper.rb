module MockableTestHelper
  def self.included(base)
    base.class_eval do
      def mock
        @mock ||= ::MiniTest::Mock.new
      end

      def expect(*args)
        self.mock.expect *args
        orig = args[0].to_s
        if ("!?".include?(orig[-1]))
          mock = "#{orig[0..-2]}_with_mock#{orig.last}"
        else
          mock = "#{orig}_with_mock"
        end
        self.class_eval <<-EOMETA
          def #{mock}(*args)
            self.mock.#{orig}(*args)
          end

          alias_method :#{orig}, :#{mock}
        EOMETA
      end


      def verify
        self.mock.verify
      end
    end
  end
end
