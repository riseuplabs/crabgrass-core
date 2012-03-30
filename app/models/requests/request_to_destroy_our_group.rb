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

  alias_attr :group, :recipient

  def self.already_exists?(options)
    pending.from_group(options[:group]).exists?
  end
  
  def validate_on_create
    if duplicate_exists?
      errors.add_to_base(:request_exists_error.t(:recipient => group.display_name))
    end
  end

  def may_create?(user)
    user.may?(:admin, group)
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
    I18n.t(:request_to_destroy_our_group_description,
              :group => group_span(group),
              :group_type => group.group_type.downcase,
              :user => user_span(created_by))
  end

  def short_description
    I18n.t(:request_to_destroy_our_group_short,
              :group => group_span(group),
              :group_type => group.group_type.downcase,
              :user => user_span(created_by))
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

  private

  def duplicate_exists?
    RequestToDestroyOurGroup.pending.to_group(group).find(:first)
  end

end
