require 'test/unit'
require 'rubygems'
require 'debugger'
require 'logger'
gem 'actionpack', '~> 3.2.19'
gem 'activerecord', '~> 3.2.19'
require 'active_record'

##
## OPTIONS
##

#
# run like so to specify arguments:
#
#   ruby test/tests.rb --rebuild
#

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby test/tests.rb [options]"
  opts.on("-b", "--rebuild", "Rebuild schema") do |b|
    options[:rebuild] = b
  end
  opts.on("-r", "--reload", "Reload fixtures") do |r|
    options[:reload] = r
  end
end.parse!

# set to true if schema changes.
REBUILD_DB = options[:rebuild]

# set to true if fixtures changes.
RELOAD_FIXTURES = options[:reload]

# set to :mysql to test aggregation BIT_OR
ADAPTER = :sqlite

# set to true to see all the sql commands
SHOW_SQL = false

##
## TEST HELPERS
##

class Object
  private
  def after_reload(model, &block)
    yield model
  end
end

['../init', 'setup_db', 'models', 'fixtures'].each do |file|
  require_relative file
end

if REBUILD_DB
  teardown_db
  setup_db
  create_fixtures
elsif RELOAD_FIXTURES
  reset_db
  create_fixtures
end

