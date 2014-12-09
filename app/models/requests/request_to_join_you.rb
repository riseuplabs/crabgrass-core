#
# An outside user requests to join a group they are not part of.
#
# recipient: the group
# requestable: not used
# created_by: person who wants in
#
class RequestToJoinYou < Request

  validates_format_of :recipient_type, with: /Group/

  validate :no_membership_yet, on: :create

  def group() recipient end

  def may_create?(user)
    created_by == user
  end

  def may_approve?(user)
    user.may?(:admin,group)
  end

  def may_destroy?(user)
    user.may?(:admin, group) or user == created_by
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def after_approval
    group.add_user! created_by
  end

  def description
    [:request_to_join_you_description, {user: user_span(created_by), group: group_span(group)}]
  end

  def short_description
    [:request_to_join_you_short, {user: user_span(created_by), group: group_span(group)}]
  end

  protected

  def no_membership_yet
    if Membership.find_by_user_id_and_group_id(created_by_id, recipient_id)
      errors.add(:base, "You are already a member")
    end
  end

  def duplicates
    self.class.pending.for_recipient(recipient).created_by(created_by)
  end

  def requestable_required?() false end
end

