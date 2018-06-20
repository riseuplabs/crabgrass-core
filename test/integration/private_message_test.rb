require 'integration_test'

class PrivateMessageTest < IntegrationTest
  def setup
    super
    @blue = users(:blue)
    @red = users(:red)
    @message = 'Hi, Red!'
  end

  def test_send_a_message_from_user_profile_without_disccussion
    login @blue
    visit @red.login.to_s
    click_on :send_message_link.t

    assert_equal "/me/messages/#{@red.login}/posts", current_path
    assert_selector('a', visible: true, text: @red.display_name.to_s)

    fill_in :post_body, with: @message
    assert_difference 'Post.count' do
      click_on :post_message.t
    end
    assert_selector('p', visible: true, text: @message)
  end

  def test_send_a_message_from_user_profile_with_disccussion
    login @blue
    Message.send from: @blue, to: @red, body: @message
    visit @red.login.to_s
    click_on :send_message_link.t

    assert_equal "/me/messages/#{@red.login}/posts", current_path
    assert_selector('a', visible: true, text: @red.display_name.to_s)
    assert_selector('p', visible: true, text: @message)

    fill_in :post_body, with: 'Second Message'
    assert_difference 'Post.count' do
      click_on :post_message.t
    end
    assert_selector('p', visible: true, text: 'Second Message')
  end
end
