module MockableTestHelper

  class ReturnValueError < StandardError
  end

  def self.included(base)
    base.class_eval do
      def mock
        @mock ||= ::MiniTest::Mock.new
      end

      # this will
      # * expect a certain function call
      # * intercept it
      # * return the given return value
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

      # this will
      # * expect a certain function call
      # * run it when it happens
      # * check if the return value is the given one
      # * raise an ReturnValueError otherwise
      def expect_or_raise(*args)
        self.mock.expect *args
        orig = args[0].to_s
        if ("!?".include?(orig[-1]))
          mock = "#{orig[0..-2]}_with_mock#{orig.last}"
          no_mock = "#{orig[0..-2]}_without_mock#{orig.last}"
        else
          mock = "#{orig}_with_mock"
          no_mock = "#{orig}_without_mock"
        end
        self.class_eval <<-EOMETA
          def #{mock}(*args)
            expected = self.mock.#{orig}(*args)
            run = #{no_mock}(*args)
            unless expected == run
              message = "Expected #{orig} to return " + expected + ".\n"
              message += "Instead it returned " + run + "."
              raise ReturnValueError.new(message)
            end
            return run
          end

          alias_method_chain :#{orig}, :mock
        EOMETA
      end

      def verify
        self.mock.verify
      end
    end
  end
end
