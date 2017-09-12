class ChatMessage < ActiveRecord::Base
  self.table_name = 'messages'

  belongs_to :channel, class_name: 'ChatChannel', foreign_key: 'channel_id'
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'

  validates_presence_of :channel, :sender

  default_scope { where(deleted_at: nil) }
  default_scope { order('created_at ASC') }

  before_create :set_sender_name
  def set_sender_name
    self.sender_name = sender.login if sender
    true
  end
end
