require 'rubygems'
require 'test/unit'
gem 'activesupport', '=2.3.11'
require 'active_support/core_ext'
require 'active_support/test_case'
gem 'activerecord', '=2.3.11'
ENV["RAILS_ENV"] = "test"

#
# taken from rails test_help
#

if defined?(ActiveRecord)
  require 'active_record/test_case'
  require 'active_record/fixtures'

  class ActiveSupport::TestCase
    include ActiveRecord::TestFixtures
    self.fixture_path = "#{RAILS_ROOT}/test/fixtures/"
    self.use_instantiated_fixtures  = false
    self.use_transactional_fixtures = true
  end

  def create_fixtures(*table_names, &block)
    Fixtures.create_fixtures(ActiveSupport::TestCase.fixture_path, table_names, {}, &block)
  end
end

begin
  require_library_or_gem 'ruby-debug'
  Debugger.start
  if Debugger.respond_to?(:settings)
    Debugger.settings[:autoeval] = true
    Debugger.settings[:autolist] = 1
  end
rescue LoadError
  # ruby-debug wasn't available so neither can the debugging be
end


##
## load all the test helpers
##

# Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }

##
## load machinist blueprints
##

# require File.expand_path(File.dirname(__FILE__) + "/blueprints")

##

class ActiveSupport::TestCase

  setup {
    # make sure we don't have any login from the last test
    User.current = nil
  }

#  self.use_transactional_fixtures = true
#  self.use_instantiated_fixtures  = false

#  include AuthenticatedTestHelper
#  include AssetTestHelper
#  include SphinxTestHelper
#  include SiteTestHelper
#  include LoginTestHelper
#  include FixtureTestHelper
#  include FunctionalTestHelper
#  include DebugTestHelper
#  include CrabgrassTestHelper

  fixtures :all
end

# we want to be able to mock our application controller

class ApplicationController
  include MockableTestHelper
end

