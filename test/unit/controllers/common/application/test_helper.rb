# require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')
require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_support/inflector'
require 'active_support/hash_with_indifferent_access' unless defined? HashWithIndifferentAccess
require 'test/unit'

RAILS_ENV='test' unless defined? RAILS_ENV

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

