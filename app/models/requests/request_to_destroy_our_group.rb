#
# A request to destroy a group.
#
#   recipient: the group to be destroyed
# requestable: the same group
#  created_by: person in group who want their group to be destroyed
#

class RequestToDestroyOurGroup < Request

  validates_format_of :recipient_type,   :with => /Group/
  validates_format_of :requestable_type, :with => /Group/
  validate :no_duplicate, :on => :create

  alias_attr :group, :recipient

  def self.already_exists?(options)
    pending.from_group(options[:group]).exists?
  end

  def may_create?(user)
    user.may?(:admin, group)
  end

  def self.may_create?(options)
    self.new(:recipient => options[:group], :requestable => options[:group]).may_create?(options[:current_user])
  end

  def may_approve?(user)
    user.may?(:admin, group) and user.id != created_by_id
  end

  alias_method :may_view?, :may_create?
  alias_method :may_destroy?, :may_create?

  def after_approval
    group.destroy_by(created_by)
  end

  def description
    [:request_to_destroy_our_group_description, {
      :group => group_span(group),
      :group_type => group.group_type.downcase,
      :user => user_span(created_by)
    }]
  end

  def short_description
    [:request_to_destroy_our_group_short, {
      :group => group_span(group),
      :group_type => group.group_type.downcase,
      :user => user_span(created_by)
    }]
  end

  protected

  def no_duplicate
    if duplicate_exists?
      errors.add_to_base(:request_exists_error.t(:recipient => group.display_name))
    end
  end

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

  private

  def duplicate_exists?
    RequestToDestroyOurGroup.pending.to_group(group).find(:first)
  end

end
