#
# Wrapper around a private post during creation.
#
# This way we have an object to hand to the policy and
# base the policy upon.
#
# Also isolate all the private message specific discussion preperation.
#
# Message.send(params)
# is equivalent to
# Message.new(params).send
#
# Both will create and return a PrivatePost object.
#
# In addition they create the necessary Relationship and Discussion.

class Message

  # create and return the post corresponding to params
  def self.send(params)
    new(params).send
  end


  def initialize(params)
    @sender = params.delete :from
    @recipient = params.delete :to
    @params = params
  end

  attr_reader :sender, :recipient

  # add a new post to the private discussion shared between this and the other_user.
  #
  # +in_reply_to+ is an optional argument for the post that this new post
  # is replying to.
  #
  # currently, this is not stored, but used to generate a more informative
  # notification on the user's wall.
  #
  def send
    relationship.send_message(body, in_reply_to)
  end

  protected

  attr_reader :params

  # ensure a relationship between this and the other user exists
  def relationship
    sender.relationships.with(recipient).first ||
      sender.add_contact!(recipient)
  end

  def body
    params[:body]
  end

  def in_reply_to
    if params[:in_reply_to_id]
      Post.find_by_id params[:in_reply_to_id]
    end
  end
end
