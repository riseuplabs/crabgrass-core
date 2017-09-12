class PrivatePost < Post
  has_one :activity,
          foreign_key: :related_id,
          dependent: :delete,
          class_name: 'Activity::MessageSent'

  has_many :private_message_notices,
           class_name: 'Notice::PrivateMessageNotice',
           as: :noticable

  def private?
    true
  end
end
