module Permission

  class TestCase < ActiveSupport::TestCase

    @@permission_module = nil

    class << self

      def tests(permission_module)
        self.permission_module = permission_module
      end

      def permission_module=(new_module)
        prepare_permission_module(new_module) if new_module
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

      include permission_module
    end

  end

end
