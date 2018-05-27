require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @sender = users(:blue)
    @recipient = users(:penguin)
  end

  def test_initial_message
    post = Message.send from: @sender, to: @recipient,
      body: 'blablabla'
    assert sending
    assert discussion = sending.discussion
    assert_equal 1, discussion.posts_count
    assert discussion.unread_by?(@recipient)
    assert !discussion.unread_by?(@sender)
  end

  def test_reply_to_same_discussion
    post = Message.send from: @sender, to: @recipient,
      body: 'blablabla'
    repl = Message.send from: @recipient, to: @sender,
      body: 'blablabla',
      in_reply_to_id: post.id
    assert discussion = recieving.discussion
    assert_equal sending.discussion, discussion
  end

  def test_reply_unread_count
    post = Message.send from: @sender, to: @recipient,
      body: 'blablabla'
    repl = Message.send from: @recipient, to: @sender,
      body: 'blablabla',
      in_reply_to_id: post.id
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
