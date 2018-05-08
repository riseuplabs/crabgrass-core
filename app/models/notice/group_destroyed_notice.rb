class Notice::GroupDestroyedNotice < Notice

  alias_attr :group, :noticable

  def button_text
  end

  def display_label
    :membership.t
  end

  def display_body
    display_attr(:body).html_safe
  end

  def redirect_object
    user.try.name || data[:user]
  end

  protected

  before_create :encode_data
  def encode_data
    self.data = {title: :notification, body: [:group_destroyed_email, {group_type: group.type, group: ('<group>%s</group>' % group.name)}]}
  end

end
