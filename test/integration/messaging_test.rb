require 'javascript_integration_test'

class MessagingTest < JavascriptIntegrationTest
  include Integration::Comments

  fixtures :users, 'castle_gates/keys'

  def test_send_message
    login users(:blue)
    send_message text, to: 'red'
    assert_content text
  end

  def test_send_message_from_discussion
    login users(:blue)
    send_message text, to: 'red'
    assert_content text
    fill_in 'post_body', with: 'other message'
    click_on 'Post Message'
    assert_selector '.private_post', text: 'other message'
    save_screenshot '/tmp/posted.png'
  end

  def test_edit_message
    new_msg = 'Now here is something new!'
    login users(:blue)
    send_message text, to: 'red'
    edit_comment text, new_msg
    assert_content new_msg
    assert_no_content text
  end

  def test_delete_message
    blue = users(:blue)
    red = users(:red)
    login blue
    new_msg = Message.send from: blue, to: red, body: text
    msg_id = "#private_post_#{new_msg.id}"

    visit "/me/messages/#{red.login}/posts"

    assert_selector msg_id

    hover_and_edit(text) do
      click_on 'Delete'
    end

    assert_no_selector msg_id
  end

  private

  def send_message(msg, options = {})
    click_on 'Messages'
    fill_in 'Recipient', with: options[:to]
    fill_in 'Message', with: msg
    click_on 'Send'
  end

  def text
    @text ||= 'we need something unique here: ' +
      Password.random(8)
  end
end
