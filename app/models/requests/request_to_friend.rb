#
# A contact request
#
# creator: user wanting a friend
# recipient: potential friend
# requestable: nil
#
#
class RequestToFriend < Request
  validates_format_of :recipient_type, with: /\AUser\z/
  validate :no_friendship_yet, on: :create

  def self.policy_class
    RequestToFriendPolicy
  end


  def no_friendship_yet
    if created_by.friendships.with(recipient_id).exists?
      errors.add(:base, 'Friendship already exists')
    end
  end

  #
  # returns existing friend request, if any.
  # requires: {:from => x, :to => y}
  #
  def self.existing(options)
    pending.created_by(options[:from]).to_user(options[:to]).first
  end

  def requestable_required?
    false
  end

  def may_create?(_user)
    true
  end

  def may_destroy?(user)
    user == recipient or user == created_by
  end

  def may_approve?(user)
    recipient == user
  end

  def may_view?(user)
    user == recipient or may_approve?(user)
  end

  def after_approval
    recipient.add_contact!(created_by, :friend)
  end

  def event
    :create_friendship
  end

  def event_attrs
    { user: recipient, other_user: created_by }
  end

  def description
    [:request_to_friend_description, { user: user_span(created_by), other_user: user_span(recipient) }]
  end

  def short_description
    [:request_to_friend_short, { user: user_span(created_by), other_user: user_span(recipient) }]
  end
end
