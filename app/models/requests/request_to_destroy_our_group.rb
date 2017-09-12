#
# A request to destroy a group.
#
#   recipient: the group to be destroyed
# requestable: the same group
#  created_by: person in group who want their group to be destroyed
#

class RequestToDestroyOurGroup < Request
  validates_format_of :recipient_type,   with: /Group/
  validates_format_of :requestable_type, with: /Group/

  alias_attr :group, :recipient

  # once the group has been deleted we do not require it anymore.
  def recipient_required?
    !approved?
  end
  alias requestable_required? recipient_required?

  def self.already_exists?(options)
    pending.from_group(options[:group]).exists?
  end

  def may_create?(user)
    user.may?(:admin, group)
  end

  def self.may_create?(options)
    new(recipient: options[:group], requestable: options[:group]).may_create?(options[:current_user])
  end

  def may_approve?(user)
    user.may?(:admin, group) and user.id != created_by_id
  end

  alias may_view? may_create?
  alias may_destroy? may_create?

  def after_approval
    group.destroy
  end

  def event
    :destroy_group
  end

  def event_attrs
    { groupname: group.name, recipient: created_by, destroyed_by: approved_by }
  end

  def description
    [:request_to_destroy_our_group_description, description_args]
  end

  def short_description
    [:request_to_destroy_our_group_description, description_args]
  end

  def description_args
    { group:      group_span,
      group_type: group.group_type,
      user:       user_span(created_by) }
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
  #   xxxx
  # end
  #
end
