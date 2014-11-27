require 'javascript_integration_test'

class MessageTest < JavascriptIntegrationTest


  def test_sending_message
    msg = "Here is my Message"
    login users(:blue)
    click_on 'Messages'
    click_on 'Send Message'
    fill_in 'Recipient', with: 'red'
    fill_in 'Message', with: msg
    click_on 'Send'
    assert_content msg
  end

end

