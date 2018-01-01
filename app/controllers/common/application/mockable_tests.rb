module Common::Application::MockableTests
  class ReturnValueError < StandardError
  end

  def self.included(base)
    return unless Rails.env.test?
    base.class_eval do
      hide_action :mock, :expect, :expect_or_raise, :verify

      def mock
        @mock ||= ::MiniTest::Mock.new
      end

      # this will
      # * expect a certain function call
      # * intercept it
      # * return the given return value
      def expect(*args)
        mock.expect *args
        orig = args[0].to_s
        mock = if '!?'.include?(orig[-1])
                 "#{orig[0..-2]}_with_mock#{orig.last}"
               else
                 "#{orig}_with_mock"
               end
        class_eval <<-EOMETA
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
        mock.expect *args
        func = args[0].to_s
        class_eval <<-EOMETA
          def #{func}(*args)
            expected = self.mock.#{func}
            run = super
            unless expected == run
              message = "Expected #{func} to return " + expected.to_s + ".\n"
              message += "Instead it returned " + run.to_s + "."
              raise ReturnValueError.new(message)
            end
            return run
          end
        EOMETA
      end

      def verify
        mock.verify
      end
    end
  end
end
