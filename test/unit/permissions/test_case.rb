module Permission

  class TestCase < ActiveSupport::TestCase

    setup :setup_controller_and_request

    @@permission_module = nil

    class << self

      def tests(permission_module)
        self.permission_module = permission_module
      end

      def permission_module=(new_module)
        prepare_controller_with_permission_module(new_module) if new_module
        write_inheritable_attribute(:permission_module, new_module)
      end

      def permission_module
        if current_permission_module = read_inheritable_attribute(:permission_module)
          current_permission_module
        else
          self.permission_module = determine_default_permission_module(name)
        end
      end

      def determine_default_permission_module(name)
        name.sub(/Test$/, '').constantize
      rescue NameError
        nil
      end

      def prepare_controller_with_permission_module(mod)
        TestController.send :include, mod
      end
    end


    def setup_controller_and_request
      @permission = self.class.permission_module
      @request = TestRequest.new
      @controller = TestController.new
      @controller.request = @request
      @controller.params = {}

    end


    class TestController
      attr_accessor :request
      attr_accessor :params

      def current_user
        self.request.session[:user]
      end
    end

    class TestRequest

      attr_writer :session

      def session
        @session || {}
      end
    end
  end

end
