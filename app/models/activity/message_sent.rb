class Activity::MessageSent < Activity

  validates_format_of :subject_type, with: /User/
  validates_presence_of :subject_id

  validates_format_of :item_type, with: /User/
  validates_presence_of :item_id

  alias_attr :user_to, :subject
  alias_attr :user_from, :item
  alias_attr :avatar, :item
  alias_attr :post_id, :related_id
  alias_attr :snippet, :extra
  alias_attr :reply, :flag

  belongs_to :post, foreign_key: :related_id

  # This is likely created via Activity.track with controller options.
  # The controller options like user may not be what we want...
  # We only trust the post.
  before_validation :extract_attrs_from_post
  def extract_attrs_from_post
    return true unless post
    self.snippet = GreenCloth.new(post.body[0..140], 'page', [:lite_mode]).to_html
    self.snippet += '...' if post.body.length > 140
    self.user = post.recipient
    self.author = post.user
  end

  protected

  before_create :set_access
  def set_access
    self.access = Activity::PRIVATE
  end

  public

  def description(view)
    url = view.send(:my_private_message_path, user_from_name)
    link_text = reply ? I18n.t(:a_reply_link) : I18n.t(:a_message_link)

    I18n.t(:activity_message_received,
             message_tag: view.link_to(link_text, url),
             other_user: user_span(:user_from),
             title: "<i>#{snippet}</i>")
  end

  def icon
    'page_message'
  end

end

