# Make double-sure the RAILS_ENV is set to test,
# so fixtures are loaded to the right database
silence_warnings { RAILS_ENV = "test" }

require 'test/unit'

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

unless defined?(FORBIDDEN_NAMES)
  FORBIDDEN_NAMES = %w{
    account admin assets avatars chat code debug do groups
    javascripts me networks page pages people pictures places issues
    session static stats stylesheets theme
  }
end
