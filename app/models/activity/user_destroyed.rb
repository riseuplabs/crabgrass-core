class Activity::UserDestroyed < Activity
  validates_format_of :subject_type, with: /\AUser\z/
  validates_presence_of :subject_id
  validates_presence_of :extra

  alias_attr :recipient,  :subject
  alias_attr :username,   :extra

  def avatar
    nil
  end

  def description(_view = nil)
    I18n.t(:activity_user_destroyed, user: username)
  end

  def icon
    'minus'
  end
end
