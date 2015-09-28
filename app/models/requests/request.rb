# -*- coding: utf-8 -*-
=begin
    create_table "requests", :force => true do |t|
      t.integer  "created_by_id"
      t.integer  "approved_by_id"

      t.integer  "recipient_id"
      t.string   "recipient_type", :limit => 5

      t.string   "email"
      t.string   "code", :limit => 8

      t.integer  "requestable_id"
      t.string   "requestable_type", :limit => 10

      t.integer  "shared_discussion_id"
      t.integer  "private_discussion_id"

      t.string   "state", :limit => 10
      t.string   "type"
      t.datetime "created_at"
      t.datetime "updated_at"

      t.integer  "site_id"
    end
=end

#
# Anytime an action needs approval, a Request is made.
# This includes invitations, requests to join, RSVP, etc.
#
class Request < ActiveRecord::Base
  include AASM

  ##
  ## ASSOCIATIONS
  ##

  belongs_to :created_by, class_name: 'User'
  belongs_to :approved_by, class_name: 'User'
  alias_method :rejected_by, :approved_by

  belongs_to :recipient, polymorphic: true
  belongs_to :requestable, polymorphic: true

  belongs_to :shared_discussion, class_name: 'Discussion', dependent: :destroy
  belongs_to :private_discussion, class_name: 'Discussion', dependent: :destroy

  has_many :notices, as: :noticable,
    dependent: :delete_all,
    class_name: 'RequestNotice'

  # most requests are non-vote based. they just need a single 'approve' action
  # to get approved
  # some requests (ex: RequestToDestroyOurGroup) are approved only
  # when they get sufficient votes for approval and (in some cases)
  # when a period of time has passed
  # 'ignore' is another vote that could be use by otherwise non-votable requests
  # so that each person has a distinct 'ignore'/'non-ignore' state
  has_many :votes, as: :votable, class_name: "RequestVote", dependent: :delete_all

  validates_presence_of :created_by
  validates_presence_of :recipient,   if: :recipient_required?
  validates_presence_of :requestable, if: :requestable_required?

  validate :no_duplicate, on: :create
  validate :check_create_permission, on: :create

  before_validation :set_default_state, on: :create

  ##
  ## FINDERS
  ##

  def self.having_state(state)
    where("requests.state = ?", state.to_s)
  end

  # i think this is a nice idea, but... i am not sure about the UI for this. by making the view dependent
  # on the user, you make it hard to find requests that are still pending but have been approved by you
  # and not others. I think it is better to show these requests as pending, but indicate in the view
  # that you have already voted on this. so, i am commented out this complicated bit of code:

  ## same as having_state, but take into account
  ## that user can vote reject/approve on some requests without changing the state
  #def :having_state_for_user(state, user)
  #  votes_conditions = if state == :pending
  #    "votes.value IS NULL AND requests.state = 'pending'"
  #  else
  #    ["votes.value = ? OR requests.state = ?", vote_value_for_state(state), state.to_s]
  #  end
  #  { :conditions => votes_conditions,
  #    :select => "requests.*",
  #    :joins => "LEFT OUTER JOIN votes ON `votes`.votable_id = `requests`.id AND `votes`.votable_type = 'Request'AND `votes`.`type` = 'RequestVote' AND votes.user_id = #{user.id}"}
  #}

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
    where(recipient_id: recipient)
  end

  def self.with_requestable(requestable)
    where(requestable_id: requestable)
  end

  def self.visible_to(user)
    where "(recipient_id = ? AND recipient_type = 'User') OR (recipient_id IN (?) AND recipient_type = 'Group') OR (created_by_id = ?)",
      user.id, user.all_group_ids, user.id
  end


  MEMBERSHIP_TYPES = [
    'RequestToJoinOurNetwork',
    'RequestToJoinUs',
    'RequestToJoinUsViaEmail',
    'RequestToJoinYou',
    'RequestToJoinYourNetwork',
    'RequestToRemoveUser'
  ]

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
    @initial_post = msg   # see build_discussion
  end

  before_save :build_discussion
  def build_discussion
    if @initial_post.present?
      self.build_shared_discussion(post: {body: @initial_post, user: created_by})
    end
  end

  #
  # Returns the entity that would make a good icon for this request.
  # Can, and should, be overridden by subclasses when appropriate.
  #
  def icon_entity
    self.created_by
  end

  ##
  ## ACTIONS
  ##

  #
  # change the state of the request, testing to see if the user is allowed to.
  #
  def set_state!(newstate, user=nil)
    if new_record?
      raise 'record must be saved first'
    end

    command = case newstate
      when 'approved' then 'approve!'
      when 'rejected' then 'reject!'
      else raise 'state must be approved or rejected'
    end

    if user.nil?
      raise_denied(nil,newstate)
    end

    self.approved_by = user  # approve or rejecte both use approved_by
    self.send(command)       # FSM call, eg approve!()

    unless self.state == newstate
      raise_denied(user, newstate)
    end

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
    set_state!('approved',user)
  end

  def reject_by!(user)
    set_state!('rejected',user)
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
  def event_attrs(); {}; end
  def description() end
  def short_description() end
  def votable?() false end

  def may_create?(user)  false end
  def may_destroy?(user) false end
  def may_approve?(user) false end
  def may_view?(user)    false end

  def after_approval() end

  def recipient_required?()   true end
  def requestable_required?() true end

  def flash_message(options = {})
    # WARNING: don't pass the whole 'options' hash here, as 'human' will
    #     add :default and :scope options, which break our translations.
    thing = self.class.model_name.human(count: options[:count])
    options.merge! thing: thing,
      recipient: recipient.try.display_name || email
    if self.errors.any?
      { type: :error,
        text: :thing_was_not_sent.t(options),
        list: self.errors.full_messages }
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
    ('<user>%s</user>' % user.name).html_safe
  end

  def group_span(group = nil)
    group ||= self.group
    return nil if group.blank?
    ('<group>%s</group>' % group.name).html_safe
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
    self.state = "pending" # needed despite FSM so that validations on create will work.
  end

  def check_create_permission
    # created_by has it's own validations - so let's not bomb out
    return if created_by.blank?
    unless may_create?(created_by)
      errors.add(:base, I18n.t(:permission_denied))
    end
  end

  def no_duplicate
    if duplicates.any?
      errors.add(:base, :request_exists_error.t(recipient: recipient.display_name))
    end
  end

  def duplicates
    self.class.pending.with_requestable(requestable).for_recipient(recipient)
  end

  def self.vote_value_for_action(vote_state)
    case vote_state.to_s
      when 'reject' then 0;
      when 'approve' then 1;
      when 'ignore' then 2;
    end
  end

  def add_vote!(response, user)
    value = self.class.vote_value_for_action(response)
    votes.by_user(user).delete_all
    votes.create!(value: value, user: user)
  end

end

