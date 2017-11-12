class PrivatePost < Post
  has_one :activity,
          foreign_key: :related_id,
          dependent: :delete,
          class_name: 'Activity::MessageSent'

  # deleted because they are also notices and Post.notices is
  # dependent: :delete_all
  has_many :private_message_notices,
           class_name: 'Notice::PrivateMessageNotice',
           as: :noticable

  def private?
    true
  end
end
