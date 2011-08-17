APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", ".."))
RAILS_ENV = 'test'
$: << File.join(APP_ROOT, "app/controllers")

# A test double for ActionController::Base
module ActionController
  class Base
    attr_accessor :params

    def self.method_missing(name, *args, &block)
    #  puts "missed #{name}"
    end
  end
end

# so we can include common application extensions
module Common
  module Application
  end
end

module ActiveRecord
  class RecordNotFound < StandardError
  end
end

require 'rubygems'
require 'test/unit'
require 'minitest/mock'
require 'active_support/core_ext'

require 'application_controller'
require 'dispatch_controller'

class Page

  def self.mock
    @mock
  end

  def self.find_by_id(id, options={})
    if id == 5 and options == {:include => nil}
      @mock = MiniTest::Mock.new
      @mock.expect :controller, "discussion_page"
      @mock.expect :is_my_page?, true
    end
  end
end

class DiscussionPageController

  attr_accessor :options

  def initialize(options)
    @options = options
  end
end

class DispatchControllerUnitTest < Test::Unit::TestCase

  def setup
    @controller = DispatchController.new
  end

  def test_dispatch_with_page_id
    @controller.params = {:_page => 'garble 5', :path => ""}
    new_controller = @controller.send :find_controller
    assert new_controller.is_a? DiscussionPageController
    assert new_controller.options[:page].is_my_page?
    assert new_controller.options[:user].nil?
    assert new_controller.options[:group].nil?
    assert new_controller.options[:pages].nil?
    Page.mock.verify
  end

end
