# = Activity
#
# Activities are used to populate the recent activity list on the dashboard.
# They are usually created by using track_action in the controllers which
# hands the current state to Tracking::Action.track
# (see Common::Tracking::Action in controllers and Tracking::Action in models)
# Activities will show up on the subjects landing page.
#
# == Database Schema:
#
#  create_table "activities", :force => true do |t|
#    t.integer  "subject_id",   :limit => 11
#    t.string   "subject_type"
#    t.string   "subject_name"
#    t.integer  "item_id",    :limit => 11
#    t.string   "item_type"
#    t.string   "item_name"
#    t.string   "type"
#    t.string   "extra"
#    t.integer  "related_id",
#    t.integer  "key",          :limit => 11
#    t.datetime "created_at"
#    t.integer  "access",       :limit => 1,  :default => 2
#    t.integer  "site_id",      :limite => 11
#  end
#
#
# related_id and extra are used for generic storage and association, whatever
# the subclass wants to use it for.
#

class Activity < ActiveRecord::Base

  # activity access (relative to self.subject):
  PRIVATE = 1  # only you can see it
  DEFAULT = 2  # your friends can see this activity for you
  PUBLIC  = 3  # anyone can see it.

  belongs_to :subject, polymorphic: true  # the "subject" is typically the actor who is doing something.
  belongs_to :item, polymorphic: true   # the "item" is the thing that is acted upon.

  before_create :set_defaults
  def set_defaults # :nodoc:
    # the key is used to filter out twin activities so that we don't show
    # duplicates. for example, if two of your friends become friends, you don't
    # need to know about it twice.
    self.key ||= rand(Time.now.to_i)

    # sometimes the subject or item may be deleted.
    # therefore, we cache the name in case the subject or item doesn't exist.
    self.subject_name ||= self.subject.name if self.subject and self.subject.respond_to?(:name)
    self.item_name  ||= self.item.name if self.item and self.item.respond_to?(:name)
  end

  ##
  ## ACTIVITY DISPLAY
  ##

  # user to be used as avatar in the activities list for the current user
  def avatar
    self.respond_to?(:user) ? self.user : self.subject
  end

  # to be defined by subclasses
  def icon()
    'exclamation'
  end

  # to be defined by subclasses
  def style()
  end

  # to be defined by subclasses
  def description(view) end

  # to be defined by subclasses
  def link() end

  # calls description, and if there is any problem, then we self destruct.
  # why? because activities hold pointers to all kinds of items. These can be
  # deleted at any time. So if there is an error, it is probably because we
  # tried to reference a deleted record.
  #
  # (normally, groups and users will not cause a problem, because most the time
  # we cache their name's at the time of the activity's creation)
  def safe_description(view=nil)
    description(view)
  rescue
    self.destroy
    nil
  end

  ##
  ## FINDERS
  ##

  def self.newest
    order('created_at DESC')
  end

  def self.unique
    group('`key`')
  end

  #
  # for 'me/activities'
  #

  def self.for_my_groups(me)
    where "(subject_type = 'Group' AND subject_id IN (?))",
      me.all_group_id_cache
  end

  def self.for_me(me)
    where "(subject_type = 'User' AND subject_id = ?)",
      me.id
  end

  def self.for_my_friends(me)
    where "(subject_type = 'User' AND subject_id IN (?) AND access != ?)",
      me.friend_id_cache,
      Activity::PRIVATE
  end

  def self.for_all(me)
    where(social_activities_scope_conditions(me, me.friend_id_cache))
  end

  # +other_users_ids_list+ should be an array of user ids whose
  # social activity should be retrieved
  # show all activity for:
  #
  # (1) subject is current_user
  # (2) subject belongs to the +other_users_ids_list+ (a list of current_user's friends or peers)
  # (3) subject is a group current_user is in.
  # (4) take the intersection with the contents of site if site.network.nil?
  def self.social_activities_scope_conditions(user, other_users_ids_list)
    [ "(subject_type = 'User'  AND subject_id = ?) OR
       (subject_type = 'User'  AND subject_id IN (?) AND access != ?) OR
       (subject_type = 'Group' AND subject_id IN (?)) ",
      user.id,
      other_users_ids_list,
      Activity::PRIVATE,
      user.all_group_id_cache]
  end

  # for user's landing page
  #
  # show all activity for:
  #
  # (1) subject matches 'user'
  #     (AND 'user' is friend of current_user)
  #
  # (3) subject matches 'user'
  #     (AND activity.public == true)
  #
  def self.for_user(user, current_user)
    if (current_user and current_user.friend_of?(user) or current_user == user)
      restricted = Activity::PRIVATE
    # elsif current_user and current_user.peer_of?(user)
    #   restricted = Activity::DEFAULT
    else
      restricted = Activity::DEFAULT
    end
    where "subject_type = 'User' AND subject_id = ? AND access > ?",
      user.id, restricted
  end

  # for group's landing page
  #
  # show all activity for:
  #
  # (1) subject matches 'group'
  #     (and current_user is a member of group)
  #
  # (2) subject matches 'group'
  #     (and activity.public == true)
  #
  def self.for_group(group, current_user)
    if current_user and current_user.member_of?(group)
      where "subject_type = 'Group' AND subject_id IN (?)",
        group.group_and_committee_ids
    else
      where "subject_type = 'Group' AND subject_id IN (?) AND access = ?",
        group.group_and_committee_ids, Activity::PUBLIC
    end
  end

  ##
  ## DISPLAY HELPERS
  ##
  ## used by the description() method of Activity subclasses
  ##

  # a safe way to reference a group, even if the group has been deleted.
  def group_span(attribute)
    item_span(attribute, 'group')
  end

  # a safe way to reference a user, even if the user has been deleted.
  def user_span(attribute)
    item_span(attribute, 'user')
  end

  def group_class(attribute)
    if group = self.send(attribute)
      group.group_type.downcase
    elsif group_type = self.send(attribute.to_s + '_type')
      I18n.t(group_type.downcase.to_sym).downcase
    end
  end

  private

  # often, stuff that we want to report activity on has already been
  # destroyed. so, if the item responds to :name, we cache the name.
  def item_span(item, type)
    # if it's a group, try to get the group name directly from the reference item
    # need to figure out if i'm the subject or item!
    if item.to_s == 'group'
      name = (self.item_type == 'Group') ? self.item.try.name : self.subject.try.name
    end
    name ||= self.send("#{item}_name") || self.send(item).try.name || I18n.t(:unknown)
    '<%s>%s</%s>' % [type, name, type]
  end

end

