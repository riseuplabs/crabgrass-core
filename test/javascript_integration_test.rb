require 'integration_test'
require 'capybara/poltergeist'

# require all javascript integration helpers
Dir[File.dirname(__FILE__) + '/helpers/integration/javascript/*.rb'].each do |file|
  require file
end

class JavascriptIntegrationTest < IntegrationTest

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new app,
      :js_errors => false,
      :inspector => true
  end
  Capybara.javascript_driver = :poltergeist


  def setup
    super
    Capybara.current_driver = Capybara.javascript_driver
    page.driver.add_headers "Accept-Language" => "en"
  end

  protected

  def clear_session
    Capybara.reset_sessions!
    page.driver.add_headers "Accept-Language" => "en"
  end
end
