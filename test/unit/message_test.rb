require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def setup
    @sender = FactoryGirl.create :user
    @recipient = FactoryGirl.create :user
  end

  def test_initial_message
    post = @sender.send_message_to! @recipient, 'blablabla'
    assert sending
    assert discussion = sending.discussion
    assert_equal 1, discussion.posts_count
    assert discussion.unread_by?(@recipient)
    assert !discussion.unread_by?(@sender)
  end

  def test_reply_to_same_discussion
    post = @sender.send_message_to! @recipient, 'blablabla'
    @recipient.send_message_to! @sender, 'blablabla', post
    assert discussion = recieving.discussion
    assert_equal sending.discussion, discussion
  end

  def test_reply_unread_count
    post = @sender.send_message_to! @recipient, 'blablabla'
    @recipient.send_message_to! @sender, 'blablabla', post
    discussion = recieving.discussion
    assert_equal 2, discussion.posts_count
    assert discussion.unread_by?(@recipient)
    assert discussion.unread_by?(@sender)
  end

  protected

  def recieving
    @receiving ||= @recipient.relationships.with(@sender).first
  end

  def sending
    @sending = @sender.relationships.with(@recipient).first
  end
end
