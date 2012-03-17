#
# A request to kick someone out of a group.
#
#   recipient: the group that has the user
# requestable: the user to be removed
#  created_by: person in group who wants to remove other user
#

class RequestToRemoveUser < VotableRequest

  validates_format_of :recipient_type,   :with => /Group/
  validates_format_of :requestable_type, :with => /User/

  alias_attr :group, :recipient
  alias_attr :user,  :requestable

  def validate_on_create
    if duplicate_exists?
      errors.add_to_base(:request_exists_error.t(:recipient => group.display_name))
    end
  end

  def self.already_exists?(options)
    pending.with_requestable(options[:user]).for_recipient(options[:group]).exists?
  end
  
  def may_create?(user)
    user.may?(:admin, group)
  end

  alias_method :may_view?, :may_create?
  alias_method :may_approve?, :may_create?

  def after_approval
    group.remove_user!(user)
  end

  def description
    :request_to_remove_user_description.t(:user => user_span(created_by),
      :member => user_span(user), :group_type => group.group_type.downcase,
      :group => group_span(group))
  end

  def short_description
    :request_to_remove_user_short.t(:user => user_span(created_by),
      :member => user_span(user), :group_type => group.group_type.downcase,
      :group => group_span(group))
  end

  protected

  def voting_population_count
    group.users.count
  end

  def instant_approval(voter)
    user == voter
  end

  private

  def duplicate_exists?
    RequestToRemoveUser.pending.to_group(group).find_by_requestable_id(user.id)
  end

end
