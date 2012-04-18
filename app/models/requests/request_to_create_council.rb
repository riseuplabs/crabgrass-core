#
# A request to create a council.
#
#   recipient: the group to get the council
# requestable: the same group
#  created_by: person in group who wants to create the council
#

class RequestToCreateCouncil < Request

  validates_format_of :recipient_type,   :with => /Group/
  validates_format_of :requestable_type, :with => /Group/

  alias_attr :group, :recipient

  def self.existing(options)
    pending.to_group(options[:group]).find(:first)
  end

  def validate_on_create
    if RequestToCreateCouncil.existing(:group => group)
      errors.add_to_base(:request_exists_error.t(:recipient => group.name))
    end
  end

  def may_create?(user)
    user.may?(:admin, group) and
    user.longterm_member_of?(group)
  end

  def self.may_create?(options)
    self.new(:recipient => options[:group], :requestable => options[:group]).may_create?(options[:current_user])
  end
  
  def may_approve?(user)
    user.may?(:admin, group) and
    user.id != created_by_id and
    user.longterm_member_of?(group)
  end

  alias_method :may_view?, :may_create?
  alias_method :may_destroy?, :may_create?

  def after_approval
    council = Council.new :name => :council.t, :created_by => created_by
    council.save!
    group.add_committee!(council)
  end

  def description
    I18n.t(:request_to_create_council_description,
              :group => group_span(group),
              :group_type => group.group_type.downcase,
              :user => user_span(created_by))
  end

  def short_description
    I18n.t(:request_to_create_council_short,
              :group => group_span(group),
              :group_type => group.group_type.downcase,
              :user => user_span(created_by))
  end

end
