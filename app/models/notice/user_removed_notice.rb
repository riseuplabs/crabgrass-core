class Notice::UserRemovedNotice < Notice

  alias_attr :group, :noticable
  
  def button_text
  end

  def display_label
    :membership.t
  end

  def display_body
    display_attr(:body).html_safe
  end
  
  protected

  before_create :encode_data
  def encode_data
    self.data = {title: "membership_notification", body: [:membership_leave_message, {group: ('<group>%s</group>' % group.name)}]}
  end

end
