#
# Otherwise known as a group membership invitation, but sent
# to an email address and not a user.
#
# email: send the request to this address.
# recipient: set once the code is redeemed.
# requestable: the group
# created_by: person who sent the invite
#
# The after_approval action of a MembershipRequest assumes that the code has
# been redeemed and an account created and that account is set to recipient.

class RequestToJoinUsViaEmail < MembershipRequest

  validates_format_of :requestable_type, with: /Group/
  validates :email, presence: true,
    email_format: true
  validates_length_of :code, in: 6..8

  def recipient_required?() false end
  def group() requestable end
  def user()  recipient end

  def may_create?(user)
    user.may?(:admin,group)
  end

  # approve must be called after redeem
  def may_approve?(user)
    user == recipient
  end

  def may_destroy?(user)
    user.may?(:admin, group)
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def description
    [:request_to_join_us_via_email_description, {email: email, group: group_span(group)}]
  end

  def short_description
    [:request_to_join_us_via_email_short, {email: email, group: group_span(group)}]
  end

  ##
  ## code handling
  ##

  def redeem_code!(user)
    if state != 'pending'
      raise ErrorMessage.new(I18n.t(:invite_error_redeemed))
    end
    self.recipient = user
    save!
  end

  before_validation :set_code, on: :create
  def set_code
    self.code = Password.random(8)
  end

  protected

  # we allow duplicate email invitations
  def no_duplicate
  end

end

