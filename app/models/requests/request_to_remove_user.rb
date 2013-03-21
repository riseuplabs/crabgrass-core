#
# A request to kick someone out of a group.=
#
#   recipient: the group that has the user
# requestable: the user to be removed
#  created_by: person in group who wants to remove other user
#

class RequestToRemoveUser < Request

  validates_format_of :recipient_type,   :with => /Group/
  validates_format_of :requestable_type, :with => /User/

  alias_attr :group, :recipient
  alias_attr :user,  :requestable

  def self.existing(options)
    pending.with_requestable(options[:user]).for_recipient(options[:group]).first
  end

  #
  # permissions
  #

  def may_create?(current_user)
    current_user.may?(:admin, group) and
    current_user.longterm_member_of?(group)
  end

  def self.may_create?(options)
    self.new(:user => options[:user], :group => options[:group]).may_create?(options[:current_user])
  end

  def may_approve?(current_user)
    current_user.may?(:admin, group) and
    current_user.id != created_by_id and
    current_user.id != user.id and
    current_user.longterm_member_of?(group)
  end

  def may_destroy?(current_user)
    current_user.may?(:admin, group) and
    current_user.id != user.id
  end

  alias_method :may_view?, :may_create?

  def after_approval
    group.remove_user!(user)
  end

  def description
    [:request_to_remove_user_description, {
      :user => user_span(created_by),
      :member => user_span(user),
      :group_type => group.group_type.downcase,
      :group => group_span(group)
    }]
  end

  def short_description
    [:request_to_remove_user_short, {
      :user => user_span(created_by),
      :member => user_span(user),
      :group_type => group.group_type.downcase,
      :group => group_span(group)
    }]
  end

  def icon_entity
    self.user
  end

  protected

  #
  # for votable, if we ever do that:
  #
  # def voting_population_count
  #   group.users.count
  # end
  #
  # def instant_approval(voter)
  #   user == voter
  # end

  private

end
