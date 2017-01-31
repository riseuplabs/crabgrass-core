require 'integration_test'
require 'capybara/poltergeist'

# require all javascript integration helpers
Dir[File.dirname(__FILE__) + '/helpers/integration/javascript/*.rb'].each do |file|
  require file
end

class JavascriptIntegrationTest < IntegrationTest
  include PageActions
  include AjaxPending
  include Autocomplete

  # transactionaly fixtures make js tests fail non deterministicly
  self.use_transactional_fixtures = false

  # only use fixtures required explicitly in the tests
  self.fixture_table_names = []

  Capybara.javascript_driver = :poltergeist

  def setup
    super
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.default_max_wait_time = 15 if ENV["TRAVIS"]
    page.driver.add_headers "Accept-Language" => "en"
  end

  protected

  def clear_session
    Capybara.reset_sessions!
    page.driver.add_headers "Accept-Language" => "en"
  end
end
