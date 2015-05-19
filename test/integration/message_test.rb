require 'javascript_integration_test'

class MessageTest < JavascriptIntegrationTest
  include Integration::Comments


  def test_sending_message
    msg = "Here is my Message"
    login users(:blue)
    send_message msg, to: 'red'
    assert_content msg
  end

  def test_editing_message
    msg = "Here is my Message"
    new_msg = "Now here is something new!"
    login users(:blue)
    send_message msg, to: 'red'
    edit_comment msg, new_msg
    assert_content new_msg
    assert_no_content msg
  end

  def send_message(msg, options = {})
    click_on 'Messages'
    fill_in 'Recipient', with: options[:to]
    fill_in 'Message', with: msg
    click_on 'Send'
  end


end

