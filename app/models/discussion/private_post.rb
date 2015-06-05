class PrivatePost < Post

  has_one :private_post_activity,
    foreign_key: :related_id,
    dependent: :delete

  def private?
    true
  end
end
