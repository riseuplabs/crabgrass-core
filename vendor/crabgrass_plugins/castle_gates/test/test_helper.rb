require 'minitest/autorun'
require 'rubygems'
begin
  require 'byebug'
rescue LoadError # ruby < 2.0.0
  require 'debugger'
end
require 'logger'
gem 'actionpack', '~> 3.2.22'
gem 'activerecord', '~> 3.2.22'
gem 'railties', '~> 3.2.22'
require 'active_record'
require 'rails/engine'

##
## OPTIONS
##

#
# run like so to specify arguments:
#
#   ruby test/tests.rb --rebuild
#

TEST_OPTIONS = {}.freeze
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby test/tests.rb [options]'
  # set to true if schema changes.
  opts.on('-b', '--rebuild', 'Rebuild schema') do |b|
    TEST_OPTIONS[:rebuild] = b
  end
  # set to true if fixtures changes.
  opts.on('-r', '--reload', 'Reload fixtures') do |r|
    TEST_OPTIONS[:reload] = r
  end
end.parse!

# set to :mysql to test aggregation BIT_OR
ADAPTER = :sqlite

# set to true to see all the sql commands
SHOW_SQL = false

##
## TEST HELPERS
##

['../init', 'setup_db', 'models', 'fixtures'].each do |file|
  require_relative file
end

if TEST_OPTIONS[:rebuild]
  teardown_db
  setup_db
  create_fixtures
elsif TEST_OPTIONS[:reload]
  reset_db
  create_fixtures
end
