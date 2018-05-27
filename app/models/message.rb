#
# Wrapper around a private post during creation.
#
# This way we have an object to hand to the policy and
# base the policy upon.
#
# Also isolate all the private message specific discussion preperation.
#

class Message
  def initialize(params)
    @sender = params.delete :sender
    @recipient = params.delete :recipient
    @params = params
  end

  attr_reader :sender, :recipient

  def save
    sender.send_message_to!(@recipient, params[:body], in_reply_to)
  end

  protected

  attr_reader :params

  # ensure a relationship between this and the other user exists
  # add a new post to the private discussion shared between this and the other_user.
  #
  # +in_reply_to+ is an optional argument for the post that this new post
  # is replying to.
  #
  # currently, this is not stored, but used to generate a more informative
  # notification on the user's wall.
  #
  def send_message_to!(other_user, body, in_reply_to = nil)
    relationship = relationships.with(other_user).first || add_contact!(other_user)
    relationship.send_message(body, in_reply_to)
  end

  def in_reply_to
    if params[:in_reply_to_id]
      Post.find_by_id params[:in_reply_to_id]
    end
  end
end
