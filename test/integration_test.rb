require 'test_helper'
require 'capybara/rails'
require 'active_support/test_case'

# require all integration helpers
Dir[File.dirname(__FILE__) + '/helpers/integration/*.rb'].each do |file|
  require file
end

class IntegrationTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include RecordTracking
  include ContentAssertions
  include PageAssertions
  include AccountManagement
  include UserRecords
  include OptionalFields
  include PageRecords

  # included last so crashes in other extensions will get logged.
  include EnhancedLogging

  protected

  def setup
    super
    Capybara.server = :webrick
    # we reset the defaults during setup because we rely on the
    # driver and the session in the enhanced_logging module.
    # Make sure to call super BEFORE the initialization in subclasses.
    Capybara.reset_sessions!
    Capybara.use_default_driver

    # sometimes slow sql queries in CI result in long wait times
    Capybara.default_max_wait_time = 5 if ENV['CI']

    reload_page_terms
  end

  # this is overwritten by JavascriptIntegrationTest.
  def clear_session
    Capybara.reset_sessions!
  end

  #
  # Page::Terms live in an MyIsam table
  # so they do not get cleaned up by transactional fixtures.
  def reload_page_terms
    return unless self.class.use_transactional_fixtures
    Page::Terms.delete_all
    ActiveRecord::FixtureSet.cache_fixtures ActiveRecord::Base.connection,
                                            'page/terms' => nil
    ActiveRecord::FixtureSet.create_fixtures Rails.root + 'test/fixtures',
                                             'page/terms'
  end

  def group
    records[:group] ||= FactoryBot.create(:group)
  end

  #
  # Helper to combine several tests into one.
  #
  # It's sometimes cumbersome to test the same thing for say all page types
  # or a number of different users.
  # assert_for_all allows to run a block for a number of objects.
  # If an assertion fails it will add information about which object
  # it failed for.
  #
  def assert_for_all(one_or_many)
    if one_or_many.respond_to? :each
      one_or_many.each_with_index do |one, i|
        begin
          yield one
        rescue MiniTest::Assertion => e
          # preserve the backtrace but add the run number to the message
          message  = "#{$ERROR_INFO} in run #{i + 1} with #{one.class.name}"
          message += " #{one}" if one.respond_to? :to_s
          raise $ERROR_INFO, message, $ERROR_INFO.backtrace
        end
      end
    else
      yield one_or_many
    end
  end
end
