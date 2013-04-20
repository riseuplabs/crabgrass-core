#
# Otherwise known as a group membership invitation
#
# recipient: person who may be added to group
# requestable: the group
# created_by: person who sent the invite
#
class RequestToJoinUs < Request

  validates_format_of :requestable_type, :with => /Group/
  validates_format_of :recipient_type, :with => /User/

  validate :no_membership_yet, :on => :create

  def group() requestable end

  def may_create?(user)
    user.may?(:admin,group)
  end

  def may_approve?(user)
    user == recipient
  end

  def may_destroy?(user)
    user.may?(:admin, group)
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def after_approval
    group.add_user! recipient
  end

  def description
    [:request_to_join_us_description, {:user => user_span(recipient), :group => group_span(group)}]
  end

  def short_description
    'user' # [:request_to_join_us_short, {:user => user_span(recipient), :group => group_span(group)}]
  end

  def icon_entity
    self.recipient
  end

  protected

  def no_membership_yet
    if Membership.find_by_user_id_and_group_id(recipient_id, requestable_id)
      errors.add_to_base(I18n.t(:membership_exists_error, :member => recipient.name))
    end
  end

end

