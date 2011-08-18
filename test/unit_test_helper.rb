ENV["RAILS_ENV"] = "test"
UNIT_TESTING = true

#
# taken from environment.rb
#

require "#{File.dirname(__FILE__)}/../lib/crabgrass/info.rb"

info "LOAD FRAMEWORK"

# Use any Rails in the 2.3.x series, greater than or equal to 2.3.11
RAILS_GEM_VERSION = '~> 2.3.11'
require "#{File.dirname(__FILE__)}/../config/boot.rb"
require "#{RAILS_ROOT}/config/directories.rb"

#
# taken from crabgrass/boot.rb
#

module Crabgrass
end

# load our core extends early, since they might be use anywhere.
Dir.glob("#{RAILS_ROOT}/lib/extends/*.rb").each do |file|
  require file
end

# load the mods plugin first, it modifies how the plugin loading works
require "#{CRABGRASS_PLUGINS_DIRECTORY}/crabgrass_mods/rails/boot"

require "#{RAILS_ROOT}/lib/crabgrass/initializer.rb"
require "#{RAILS_ROOT}/lib/crabgrass/conf.rb"

# load configuration file
Conf.load("crabgrass.#{RAILS_ENV}.yml")

begin
  Conf.secret = File.read(CRABGRASS_SECRET_FILE).chomp
rescue
  unless ARGV.first == "create_a_secret"
    raise "Can't load the secret key from file #{CRABGRASS_SECRET_FILE}. Have you run 'rake create_a_secret'?"
  end
end

#
# taken from environment.rb
#


Crabgrass::Initializer.run do |config|
  info "LOAD CONFIG BLOCK"

  config.eager_load_paths = ["#{RAILS_ROOT}/app/models"]
  config.autoload_paths += %w(activity assets associations discussion chat observers profile poll task tracking requests mailers).collect{|dir|"#{RAILS_ROOT}/app/models/#{dir}"}

  # this is required because we have a mysql specific fulltext index.
  config.active_record.schema_format = :sql

    # Activate observers that should always be running
  config.active_record.observers = :user_observer, :membership_observer,
    :group_observer, :relationship_observer, :post_observer, :page_tracking_observer,
    :request_to_destroy_our_group_observer

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  config.active_record.default_timezone = :utc

  config.action_mailer.perform_deliveries = false

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  config.active_record.default_timezone = :utc

  # required, but not included with crabgrass:
  config.gem 'i18n', :version => '~> 0.5'
  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '~> 1.3'
  config.gem 'will_paginate', :version => '~> 2.3'

  config.gem 'RedCloth', :version => '~> 4.2'
  config.gem 'hpricot', :version => '~> 0.8'

  # required, included with crabgrass
  config.gem 'riseuplabs-greencloth', :lib => 'greencloth'
  config.gem 'riseuplabs-undress', :lib => 'undress/greencloth'
  config.gem 'riseuplabs-uglify_html', :lib => 'uglify_html'

  # not required, but a really good idea
  config.gem 'mime-types', :lib => 'mime/types'

  # allow plugins in more places
  [CRABGRASS_PLUGINS_DIRECTORY, PAGES_DIRECTORY].each do |path|
    config.plugin_paths << path
  end
## GEMS REQUIRED FOR TESTS
##

config.gem 'machinist', :version => '~> 1.0' # switch to v2 when stable.
config.gem 'faker'
config.gem 'minitest', :lib => 'minitest/autorun'

DEFAULT_INFO_LEVEL = 0

require "#{RAILS_ROOT}/lib/crabgrass/debug.rb"

end

#
# test unit
#

require 'test/unit'


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

 Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }

##
## load machinist blueprints
##

 require File.expand_path(File.dirname(__FILE__) + "/blueprints")

##

class ActiveSupport::TestCase

  setup {
    # make sure we don't have any login from the last test
    User.current = nil
  }

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  include AuthenticatedTestHelper
  include AssetTestHelper
  include SphinxTestHelper
  include SiteTestHelper
  include LoginTestHelper
  include FixtureTestHelper
  include FunctionalTestHelper
  include DebugTestHelper
  include CrabgrassTestHelper

  fixtures :all
end

# we want to be able to mock our application controller

class ApplicationController
  include MockableTestHelper
end

