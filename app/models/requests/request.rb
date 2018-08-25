# -*- coding: utf-8 -*-
#     create_table "requests", :force => true do |t|
#       t.integer  "created_by_id"
#       t.integer  "approved_by_id"
#
#       t.integer  "recipient_id"
#       t.string   "recipient_type", :limit => 5
#
#       t.string   "email"
#       t.string   "code", :limit => 8
#
#       t.integer  "requestable_id"
#       t.string   "requestable_type", :limit => 10
#
#       t.integer  "shared_discussion_id"
#       t.integer  "private_discussion_id"
#
#       t.string   "state", :limit => 10
#       t.string   "type"
#       t.datetime "created_at"
#       t.datetime "updated_at"
#
#       t.integer  "site_id"
#     end

#
# Anytime an action needs approval, a Request is made.
# This includes invitations, requests to join, RSVP, etc.
#
class Request < ApplicationRecord
  include AASM

  ##
  ## ASSOCIATIONS
  ##

  belongs_to :created_by, class_name: 'User'
  belongs_to :approved_by, class_name: 'User'
  alias rejected_by approved_by

  belongs_to :recipient, polymorphic: true
  belongs_to :requestable, polymorphic: true

  belongs_to :shared_discussion, class_name: 'Discussion', dependent: :destroy
  belongs_to :private_discussion, class_name: 'Discussion', dependent: :destroy

  has_many :notices, as: :noticable,
                     dependent: :delete_all,
                     class_name: 'Notice::RequestNotice'

  validates_presence_of :created_by
  validates_presence_of :recipient,   if: :recipient_required?
  validates_presence_of :requestable, if: :requestable_required?

  validate :no_duplicate, on: :create
  validate :check_create_permission, on: :create

  before_validation :set_default_state, on: :create

  ##
  ## ACCESS
  ##

  def self.policy_class
    RequestPolicy
  end

  ##
  ## FINDERS
  ##

  def self.having_state(state)
    where('requests.state = ?', state.to_s)
  end

  def self.pending
    where("state = 'pending'")
  end

  def self.by_created_at
    order('created_at DESC')
  end

  def self.by_updated_at
    order('updated_at DESC')
  end

  def self.created_by(user)
    where(created_by_id: user)
  end

  def self.to_user(user)
    where(recipient_id: user, recipient_type: 'User')
  end

  # you only get to approve group requests for groups that you are an admin for
  def self.approvable_by(user)
    where "(recipient_id = ? AND recipient_type = 'User') OR (recipient_id IN (?) AND recipient_type = 'Group')",
          user.id, user.admin_for_group_ids
  end

  def self.to_or_created_by_user(user)
    # you only get to approve group requests for groups that you are an admin for
    where "(recipient_id = ? AND recipient_type = 'User') OR (recipient_id IN (?) AND recipient_type = 'Group') OR (created_by_id = ?)",
          user.id, user.admin_for_group_ids, user.id
  end

  def self.to_group(group)
    where(recipient_id: group, recipient_type: 'Group')
  end

  def self.from_group(group)
    where(requestable_id: group, requestable_type: 'Group')
  end

  def self.regarding_group(group)
    where '(recipient_id = ? AND recipient_type = ?) OR (requestable_id = ? AND requestable_type = ?)',
          group.id, 'Group', group.id, 'Group'
  end

  def self.for_recipient(recipient)
    where(recipient: recipient)
  end

  def self.with_requestable(requestable)
    where(requestable: requestable)
  end

  def self.visible_to(user)
    visibility_condition = <<-EOSQL
    (recipient_id = :id AND recipient_type = 'User') OR
    (recipient_id IN (:group_ids) AND recipient_type = 'Group') OR
    (requestable_id IN (:group_ids) AND requestable_type = 'Group') OR
    (created_by_id = :id)
    EOSQL
    where visibility_condition, id: user.id, group_ids: user.all_group_ids
  end

  MEMBERSHIP_TYPES = %w[
    RequestToJoinOurNetwork
    RequestToJoinUs
    RequestToJoinUsViaEmail
    RequestToJoinYou
    RequestToJoinYourNetwork
    RequestToRemoveUser
    RequestToRemoveGroup
  ].freeze

  #
  # find only requests related to membership.
  # maybe we should add a "membership?" column?
  #
  def self.membership_related
    where(type: MEMBERSHIP_TYPES)
  end

  ##
  ## ATTRIBUTES
  ##

  def name
    self.class.name.underscore
  end

  #
  # Allows Request.create(..., :message => 'hi')
  #
  def message=(msg)
    @initial_post = msg # see build_discussion
  end

  before_save :build_discussion
  def build_discussion
    if @initial_post.present?
      build_shared_discussion(post: { body: @initial_post, user: created_by })
    end
  end

  #
  # Returns the entity that would make a good icon for this request.
  # Can, and should, be overridden by subclasses when appropriate.
  #
  def icon_entity
    created_by
  end

  ##
  ## ACTIONS
  ##

  #
  # change the state of the request, testing to see if the user is allowed to.
  #
  def set_state!(newstate, user = nil)
    raise 'record must be saved first' if new_record?

    command = case newstate
              when 'approved' then 'approve!'
              when 'rejected' then 'reject!'
              else raise 'state must be approved or rejected'
    end

    raise_denied(nil, newstate) if user.nil?

    self.approved_by = user # approve or rejecte both use approved_by
    send(command) # FSM call, eg approve!()

    raise_denied(user, newstate) unless state == newstate

    save!
  end

  def raise_denied(user, state)
    raise PermissionDenied.new(:not_allowed_to_respond_to_request.t(user: user.try(:name), command: I18n.t(state)))
  end

  #
  # an easy method to record a user's response to this request.
  # one of :approve, :reject, :destroy
  # (todo: add support for :ignore)
  #
  def mark!(as, user)
    case as
    when :approve
      approve_by!(user)
    when :reject
      reject_by!(user)
    when :destroy
      destroy_by!(user)
    end
  end

  def approve_by!(user)
    set_state!('approved', user)
  end

  def reject_by!(user)
    set_state!('rejected', user)
  end

  def destroy_by!(user)
    if user and may_destroy?(user)
      destroy
    else
      raise_denied(user, :destroy)
    end
  end

  # triggered by FSM
  def approval_allowed?
    may_approve?(approved_by)
  end

  ##
  ## TO OVERRIDE
  ##

  def event() end

  def event_attrs
    {}
  end

  def description() end

  def short_description() end

  def may_create?(_user)
    false
  end

  def may_destroy?(_user)
    false
  end

  def may_approve?(_user)
    false
  end

  def may_view?(_user)
    false
  end

  def after_approval() end

  def recipient_required?
    true
  end

  def requestable_required?
    true
  end

  def flash_message(options = {})
    # WARNING: don't pass the whole 'options' hash here, as 'human' will
    #     add :default and :scope options, which break our translations.
    thing = self.class.model_name.human(count: options[:count])
    options[:thing] = thing
    options[:recipient] = recipient.try.display_name || email
    if errors.any?
      { type: :error,
        text: :thing_was_not_sent.t(options),
        list: errors.full_messages }
    else
      { type: :success,
        text: :thing_was_sent.t(options) }
    end
  end

  ##
  ## finite state machine
  ##
  ## There’s a time when the operation of the machine becomes so odious, makes
  ## you so sick at heart, that you can't take part, you can’t even passively
  ## take part, and you’ve got to put your bodies upon the gears and upon the
  ## wheels, upon the levers, upon all the apparatus, and you’ve got to make it
  ## stop! And you’ve got to indicate to the people who run it, to the people
  ## who own it, that unless you’re free, the machine will be prevented from
  ## working at all! --Mario Savio
  ##

  aasm column: :state, whiny_transitions: false do
    state :pending, initial: true
    state :approved, after_commit: :after_approval
    state :rejected

    event :approve do
      transitions from: :pending,  to: :approved, guard: :approval_allowed?
      transitions from: :rejected, to: :approved, guard: :approval_allowed?
    end
    event :reject do
      transitions from: :pending,  to: :rejected, guard: :approval_allowed?
    end
  end

  ##
  ## DISPLAY
  ##

  #
  # used by subclass's description()
  # the text is not html escaped, so please don't change these to display_name
  #
  def user_span(user = nil)
    user ||= self.user
    return nil if user.blank?
    format('<user>%s</user>', user.name).html_safe
  end

  def group_span(group = nil)
    group ||= self.group
    return nil if group.blank?
    format('<group>%s</group>', group.name).html_safe
  end

  def network_span(network = nil)
    network ||= self.network
    return nil if network.blank?
    format('<network>%s</network>', network.name).html_safe
  end

  #
  # all subclasses must defined 'description()' that returns a two element array:
  # a symbol for i18n and a hash for macro expansion.
  #
  def display_description
    I18n.t(*description)
  end

  def display_short_description
    I18n.t(*short_description)
  end

  ##
  ## DESTRUCTION
  ##

  # destroy all requests relating to this user
  def self.destroy_for_user(user)
    destroy_all ['created_by_id = ?', user.id]
    destroy_all ["recipient_id = ? AND recipient_type = 'User'", user.id]
  end

  # destroy all requests relating to this group
  # except the request to destroy the group
  def self.destroy_for_group(group)
    regarding_group(group).where("type != 'RequestToDestroyOurGroup'").destroy_all
  end

  protected

  ##
  ## VALIDATIONS
  ##

  def set_default_state
    self.state = 'pending' # needed despite FSM so that validations on create will work.
  end

  def check_create_permission
    # created_by has it's own validations - so let's not bomb out
    return if created_by.blank?
    errors.add(:base, I18n.t(:permission_denied)) unless may_create?(created_by)
  end

  def no_duplicate
    if duplicates.any?
      errors.add(:base, :request_exists_error.t(recipient: recipient.display_name))
    end
  end

  def duplicates
    self.class.pending.with_requestable(requestable).for_recipient(recipient)
  end
end
