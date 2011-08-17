APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", ".."))
$: << File.join(APP_ROOT, "app/controllers")

# A test double for ActionController::Base
module ActionController
  class Base
    def self.protect_from_forgery; end

    def self.method_missing(name, *args, &block)
      puts "missed #{name}"
    end
  end
end

require 'application_controller'
require 'dispatch_controller'
require 'test/unit'

class DispatchControllerUnitTest < Test::Unit::TestCase

  def setup
    @controller = DispatchController.new
  end

  def test_process
    assert @controller.respond_to? :process
  end

end
