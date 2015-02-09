# MessagePage class has been deleted a while ago,
class MessagePage < Page

  def convert
    turn_into_messages
    destroy
  end

  protected
  def turn_into_messages
    return unless discussion
    discussion.posts.each do |post|
      create_message_from_post(post)
    end
  end


  def create_message_from_post(post)
    text = post.body
    sender = post.user
    receiver = users.detect {|u| u != sender}

    return if sender.blank? || receiver.blank? || text.blank?

    # create the new message
    new_post = sender.send_message_to!(receiver, text)

    disable_timestamps
    new_post.update_attributes({updated_at: post.updated_at, created_at: post.created_at})
  ensure
    enable_timestamps
  end

  def disable_timestamps
    PrivatePost.record_timestamps = false
    Post.record_timestamps = false
  end

  def enable_timestamps
    PrivatePost.record_timestamps = true
    Post.record_timestamps = true
  end

end
