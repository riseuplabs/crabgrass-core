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
  alias_method :requestable_required?, :recipient_required?

  def self.already_exists?(options)
    pending.from_group(options[:group]).exists?
  end

  def may_create?(user)
    user.may?(:admin, group)
  end

  def self.may_create?(options)
    self.new(recipient: options[:group], requestable: options[:group]).may_create?(options[:current_user])
  end

  def may_approve?(user)
    user.may?(:admin, group) and user.id != created_by_id
  end

  alias_method :may_view?, :may_create?
  alias_method :may_destroy?, :may_create?

  def after_approval
    group.destroy_by(created_by)
  end

  # these are hacky workaround for the fact that we have no
  # access to the group itself anymore.
  # TODO: link the request to the activity which still remembers the group name
  def description
    [:request_to_destroy_our_group_description, {
      group: I18n.t(:group),
      group_type: I18n.t(:deleted),
      user: user_span(created_by)
    }]
  end

  def short_description
    [:request_to_destroy_our_group_short, {
      group: I18n.t(:group),
      group_type: I18n.t(:deleted),
      user: user_span(created_by)
    }]
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
