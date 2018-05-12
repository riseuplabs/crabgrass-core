class PrivatePost < Post
  # deleted because they are also notices and Post.notices is
  # dependent: :delete_all
  has_many :private_message_notices,
           class_name: 'Notice::PrivateMessageNotice',
           as: :noticable

  def private?
    true
  end
end
