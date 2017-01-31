# user to user relationship

class User::Relationship < ActiveRecord::Base
  self.table_name = :relationships

  belongs_to :user
  belongs_to :contact, class_name: 'User', foreign_key: :contact_id
  belongs_to :discussion, dependent: :destroy, inverse_of: :relationships

  def self.with(user)
    where(contact_id: user)
  end

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

  def send_message(body, in_reply_to = nil)
    ensure_discussion

    in_reply_to = nil if in_reply_to.try.user_id == id

    discussion.increment_unread_for!(contact)
    PrivatePost.create body: body,
      in_reply_to: in_reply_to,
      discussion: discussion,
      recipient: contact,
      user: user
  end

  def ensure_discussion(*attrs)
    return if discussion.present?
    create_discussion.tap do |discuss|
      inverse.update_attribute :discussion, discuss
      save
    end
  end

  def inverse
    @inverse ||= self.class.where(user_id: contact, contact_id: user).first
  end
end
