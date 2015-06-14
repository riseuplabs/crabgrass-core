require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def setup
    @sender = FactoryGirl.create :user
    @recipient = FactoryGirl.create :user
  end

  def test_initial_message
    post = @sender.send_message_to! @recipient, 'blablabla'
    assert send_rel = @sender.relationships.with(@recipient)
    assert discussion = send_rel.discussion
    assert_equal 1, discussion.posts_count
    assert discussion.unread_by?(@recipient)
    assert !discussion.unread_by?(@sender)
  end

  def test_reply_to_same_discussion
    post = @sender.send_message_to! @recipient, 'blablabla'
    send_rel = @sender.relationships.with(@recipient)
    @recipient.send_message_to! @sender, 'blablabla', post
    assert recieve_rel = @recipient.relationships.with(@sender)
    assert discussion = recieve_rel.discussion
    assert_equal send_rel.discussion, discussion
  end

  def test_reply_unread_count
    post = @sender.send_message_to! @recipient, 'blablabla'
    @recipient.send_message_to! @sender, 'blablabla', post
    recieve_rel = @recipient.relationships.with(@sender)
    discussion = recieve_rel.discussion
    assert_equal 2, discussion.posts_count
    assert discussion.unread_by?(@recipient)
    assert discussion.unread_by?(@sender)
  end

end
