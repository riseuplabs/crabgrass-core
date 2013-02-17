#require 'rubygems'
# we need to require test/unit because ActiveSupport::TestCase
# derives from it and mocha will not patch it if it is not loaded
# so the Mocha::API would not be available in AS::TestCase
require 'test/unit'

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
if defined?(UNIT_TESTING)
  require File.expand_path(File.dirname(__FILE__) + "/unit/test_help")
else
  require 'rails/test_help'
end

##
## load all the test helpers
##

Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }

##
## misc.
##

require 'factory_girl_rails'

#include ActionController::Assertions::ResponseAssertions
#ActionController::TestCase.send(:include, FunctionalTestHelper) unless #ActionController::TestCase.included_modules.include?(FunctionalTestHelper)

class ActiveSupport::TestCase
  # only for Machinist v2
  # setup { Machinist.reset_before_test }

  #  setup {
  #    # Make sure Faker generates random but predictable content
  #    # https://github.com/technoweenie/machinist
  #    # Sham.reset
  #   }

  setup {
    # make sure we don't have any login from the last test
    User.current = nil
  }

  include AuthenticatedTestHelper
  include AssetTestHelper
  include SphinxTestHelper
  include SiteTestHelper
  include LoginTestHelper
  include FixtureTestHelper
  include FunctionalTestHelper
  include DebugTestHelper
  include CrabgrassTestHelper

  # fixtures :all
end

##
## Integration Tests
## some special rules for integration tests
##

class ActionDispatch::IntegrationTest

  #
  # we load all fixtures because webrat integration test should see exactly
  # the same thing the user sees in development mode.
  # using self.inherited to ensure all fixtures are being loaded only if some
  # integration tests are being defined
  #
  def self.inherited(subclass)
    subclass.fixtures :all
  end
end

# ActiveSupport will define this, if it doesn't find it.
# It uses StandardError as the superclass though, instead of Exception,
# so that will generate a "superclass mismatch" error.
if Mocha.const_defined? :ExpectationError
  Mocha.__send__ :remove_const, :ExpectationError
end

#
# mocha must be required last.
# the libraries that it patches must be loaded before it is.
#
require 'mocha'

# wtf?
unless Mocha.const_defined? :ExpectationError
  class Mocha::ExpectationError < Exception
  end
end

# ActiveSupport::HashWithIndifferentAccess#convert_value calls 'class' and 'is_a?'
# on all values. This happens when assembling 'assigns' in tests.
# This little hack will make those tests pass.
MiniTest::Mock.class_eval do
  def class
    MiniTest::Mock
  end

  def is_a?(klass)
    false
  end
end
