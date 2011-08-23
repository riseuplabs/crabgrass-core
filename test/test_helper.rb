#require 'rubygems'
#require 'test/unit'  # I don't know why, but a bunch of tests fail
#                     # if test/unit is not included early on.

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
if defined?(UNIT_TESTING)
  require File.expand_path(File.dirname(__FILE__) + "/unit/test_help")
else
  require 'test_help'
end

##
## load all the test helpers
##

Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }

##
## load machinist blueprints
##

require File.expand_path(File.dirname(__FILE__) + "/blueprints")


##
## misc.
##

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

# we want to be able to mock our application controller
class ApplicationController
  include MockableTestHelper
end

##
## Integration Tests
## some special rules for integration tests
##

class ActionController::IntegrationTest

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
