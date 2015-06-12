# user to user relationship

class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, class_name: 'User', foreign_key: :contact_id
  belongs_to :discussion, dependent: :destroy, inverse_of: :relationships

  # mark as read or unread the discussion on this relationship
  def mark!(as)
    # set a new value for the unread_count field
    new_unread_count = nil

    if as == :read
      new_unread_count = 0
    elsif as == :unread
      # mark unread if necessary
      if self.unread_count.blank? or self.unread_count < 1
        new_unread_count = 1
      end
    end

    self.update_attribute(:unread_count, new_unread_count) if new_unread_count
  end

  def send_message(body, in_reply_to)
    create_discussion if discussion.blank?

    in_reply_to = nil if in_reply_to.user_id == id

    if in_reply_to && in_reply_to.user_id != contact_id
        # we should never get here normally, this is just a sanity check
        raise ErrorMessage.new("Ugh. The user and the post you are replying to don't match.")
    end

    discussion.increment_unread_for!(contact)
    discussion.create_post body: body,
      in_reply_to: in_reply_to,
      type: "PrivatePost",
      recipient: contact,
      user: self
  end

  def discussion=(val)
    super
    inverse.discussion = val
  end

  before_save :sync_inverse

  def sync_inverse
    if discussion_id_changed?
      inverse.save
    end
  end

  def inverse
    @inverse ||= Relationship.where(user_id: contact, contact_id: user).first
  end
end
