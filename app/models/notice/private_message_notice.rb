class PrivateMessageNotice < Notice
  alias_attr :private_message, :noticable
  attr_accessor :message
  attr_accessor :from

  class << self
    alias_method :find_all_by_private_message, :find_all_by_noticable
    alias_method :destroy_all_by_private_message, :destroy_all_by_noticable

    def create!(args={})
      super(args)
    end

  end

  ##
  ## DISPLAY
  ##

  def display_label
    :private_message_notice.t
  end

  def display_title
     I18n.t(:unread_private_message, :user => data[:from])
  end

  def display_body_as_quote?
    true
  end

  def display_body
    # this is now post.body_html
    data[:message]
  end

  def button_text
    :show_thing.t(:thing => :message.t)
  end

  def noticable_path
    :me_discussion_posts_path
  end

  def noticable
    data[:from]
  end

  protected

  before_create :encode_data
  def encode_data
    self.data = {:message => message, :from => from.name}
  end

  before_create :set_avatar
  def set_avatar
    self.avatar.id = from.avatar_id if from.avatar_id
  end

end
