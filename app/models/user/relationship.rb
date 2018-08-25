# user to user relationship

class User::Relationship < ApplicationRecord
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
      new_unread_count = 1 if unread_count.blank? or unread_count < 1
    end

    update_attribute(:unread_count, new_unread_count) if new_unread_count
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

  def ensure_discussion(*_attrs)
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
