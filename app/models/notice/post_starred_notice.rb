class Notice::PostStarredNotice < Notice

  alias_attr :post, :noticable
  attr_accessor :from

  def display_title
    I18n.t :activity_twinkled,
      user: data[:from], post: display_body.truncate(39)
  end

  def display_body_as_quote?
    true
  end

  def display_body
    noticable.try.body || ""
  end

  def redirect_path
    :post_path
  end

  def button_text
    :show_thing.t(thing: :page.t)
  end

  before_create :encode_data
  def encode_data
    self.avatar_id = from.try.avatar_id
    self.data = {from: from.try.name}
  end

end

