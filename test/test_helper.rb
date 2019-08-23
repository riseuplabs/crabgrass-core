require 'simplecov' if ENV['COVERAGE']
require 'minitest/autorun'

ENV['RAILS_ENV'] = 'test'
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')
require 'rails/test_help'

##
## load all the test helpers
##

Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each { |file| require file }

##
## misc.
##

class ActiveSupport::TestCase
  include AuthenticatedTestHelper
  include AssetTestHelper
  include LoginTestHelper
  include FixtureTestHelper
  include FunctionalTestHelper
  include DebugTestHelper
  include CrabgrassTestHelper
  # for fixture_file_upload
  include ActionDispatch::TestProcess

  fixtures :all
  set_fixture_class castle_gates_keys: CastleGates::Key,
                    federatings: Group::Federating,
                    memberships: Group::Membership,
                    relationships: User::Relationship,
                    taggings: ActsAsTaggableOn::Tagging,
                    tags: ActsAsTaggableOn::Tag,
                    tokens: User::Token,
                    'page/terms' => Page::Terms
end

require 'factory_bot'

class FactoryBot::SyntaxRunner
  # for fixture_file_upload
  include ActionDispatch::TestProcess

  def self.fixture_path
    ActionController::TestCase.fixture_path
  end
end

##
## Integration Tests
## some special rules for integration tests
##

# ActiveSupport::HashWithIndifferentAccess#convert_value calls 'class'
# and 'is_a?' on all values. This happens when assembling 'assigns' in
# tests.
# This little hack will make those tests pass.
MiniTest::Mock.class_eval do
  def class
    MiniTest::Mock
  end

  def is_a?(_klass)
    false
  end
end
