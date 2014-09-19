require 'integration_test'
require 'capybara/poltergeist'

# require all javascript integration helpers
Dir[File.dirname(__FILE__) + '/helpers/integration/javascript/*.rb'].each do |file|
  require file
end

class JavascriptIntegrationTest < IntegrationTest
  include PageActions

  Capybara.javascript_driver = :poltergeist

  def setup
    super
    Capybara.current_driver = Capybara.javascript_driver
    page.driver.add_headers "Accept-Language" => "en"
  end

  def teardown
    Capybara.use_default_driver
    super
  end

  protected

  def clear_session
    Capybara.reset_sessions!
    page.driver.add_headers "Accept-Language" => "en"
  end
end
