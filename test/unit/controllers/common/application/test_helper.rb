require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Common
  module Application
    class StubController

      attr_writer :params

      def params
        @params ||= {:controller => 'stub'}
      end

      def self.helpers
        @helpers ||= []
      end

      def self.helper_method(*names)
        helpers << names
      end

    end
  end
end

