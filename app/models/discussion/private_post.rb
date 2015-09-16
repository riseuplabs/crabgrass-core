class PrivatePost < Post

  has_one :activity,
    foreign_key: :related_id,
    dependent: :delete,
    class_name: 'Activity::MessageSent'

  def private?
    true
  end
end
