class Notice::UserRemovedNotice < Notice

  alias_attr :group, :noticable
  
  def button_text
    :show_thing.t(thing: :request.t)
  end

  def display_label
    :membership.t
  end

  def display_body
    display_attr(:body).html_safe
  end

  def redirect_path # FIXME: where to redirect?
    :group_path
  end
  
  # object to hand to redirect path, defaults to noticable
  def redirect_object
    :group
  end
  
  protected

  before_create :encode_data
  def encode_data
    self.data = {title: "membership_notification", body: [:membership_leave_message, {group: ('<group>%s</group>' % group.name).html_safe}]}
  end


end
