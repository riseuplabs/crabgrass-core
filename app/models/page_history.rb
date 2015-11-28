class PageHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :page
  belongs_to :item, polymorphic: true

  validates_presence_of :user, :page

  serialize :details, Hash

  after_create :send_single_notification, if: :single_notification_wanted?

  def send_single_notification
    return if self.reload.notification_sent?
    Mailer::PageHistory.deliver_updates_for page,
      to: recipients_for_single_notification
  end

  handle_asynchronously :send_single_notification

  # TODO: Let's wait 30 minutes so notifications for all changes to the same page
  # within that timeframe can be combined.
  #   run_at: Proc.new { 30.minutes.from_now }

  def single_notification_wanted?
    recipients_for_single_notification.present?
  end

  # all subclasses use the same partial
  def to_partial_path
    'page_histories/page_history'
  end

  def self.digested_with(page_history)
    where(page_id: page_history.page_id).
      where("created_at > #{page_history.created_at - 1.day}").
      where("created_at < #{page_history.created_at + 1.day}")
  end

  def self.pending_notifications
    where notification_sent_at: nil
  end

  def notification_sent?
    notification_sent_at.present?
  end

  def recipients_for_single_notification
    page.users.where(receive_notifications: 'Single').
      where(user_participations: {watch: true})
  end

  def description_key
    self.class.name.underscore.gsub('/', '_')
  end

  # params to substitute in the translation of the description key
  def description_params
    { user_name: user_name, item_name: item_name }
  end

  def user_name
    user.try.display_name || "Unknown/Deleted"
  end

  def item_name
    case item
    when Group then item.full_name
    when User then item.display_name
    else "Unknown/Deleted"
    end
  end


  # no details by default
  def details_key; end

  protected

  def page_updated_at
    Page.update_all(["updated_at = ?", created_at], ["id = ?", page.id])
  end
end

# Factory class for the different page updates
class PageHistory::Update < PageHistory
  def self.pick_class(attrs = {})
    class_for_update(attrs[:page])
  end

  protected

  def self.class_for_update(page)
    return PageHistory::MakePrivate if page.marked_as_private?
    return PageHistory::MakePublic if page.marked_as_public?
    # return PageHistory::ChangeOwner if page.owner_id_changed?
  end
end
class PageHistory::MakePublic     < PageHistory; end
class PageHistory::MakePrivate    < PageHistory; end

class PageHistory::PageCreated < PageHistory
  after_save :page_updated_at

  def description_key
    :page_history_user_created_page
  end
end

class PageHistory::ChangeTitle < PageHistory
  before_save :add_details
  after_save :page_updated_at

  def add_details
    self.details = details_from_page
  end

  def details_key
    :page_history_details_change_title
  end

  def details_from_page
    {
      from: page.previous_changes["title"].first,
      to: page.title
    }
  end
end

class PageHistory::Deleted < PageHistory
  after_save :page_updated_at

  def description_key
    :page_history_deleted_page
  end
end

class PageHistory::UpdatedContent < PageHistory
  after_save :page_updated_at
end

# Factory class for the different page updates
# To track updates to participations:
#  * inherit directly from this class
#  * define self.tracks on your class to return true for changes that should
#    be tracked.
# Changes will be a ActiveModel::Dirty changeset. You can use the activated
# and deactivated helper methods if you only need to look at the boolean value.
class PageHistory::UpdateParticipation < PageHistory
  def self.pick_class(attrs = {})
    class_for_update(attrs[:participation])
  end

  protected

  def self.class_for_update(participation)
    subclasses.detect{|klass|
      klass.tracks participation.previous_changes, participation
    }
  end

  def self.tracks(changes, part); false; end

  def self.activated(old = nil, new = nil)
    new && !old
  end

  def self.deactivated(old = nil, new = nil)
    old && !new
  end
end

class PageHistory::AddStar < PageHistory::UpdateParticipation
  def self.tracks(changes, _part)
    activated(*changes[:star])
  end
end

class PageHistory::RemoveStar < PageHistory::UpdateParticipation
  def self.tracks(changes, _part)
    deactivated(*changes[:star])
  end
end

class PageHistory::StartWatching  < PageHistory::UpdateParticipation
  def self.tracks(changes, _part)
    activated(*changes[:watch])
  end
end

class PageHistory::StopWatching  < PageHistory::UpdateParticipation
  def self.tracks(changes, _part)
    deactivated(*changes[:watch])
  end
end

# Module for the methods shared between
# GrantGroupAccess and GrantUserAccess.
module PageHistory::GrantAccess
  extend ActiveSupport::Concern

  def participation=(part)
    self.access = access_from_participation(part)
  end

  # participations use a different naming scheme for access levels
  # TODO: unify these.
  ACCESS_FROM_PARTICIPATION_SYM = {
    view:  :read,
    edit:  :write,
    admin: :full
  }
  def access_from_participation(participation = nil)
    ACCESS_FROM_PARTICIPATION_SYM[participation.try.access_sym]
  end

  def description_key
    key = super
    key.sub!('grant', 'granted')
  end

  def access
    details[:access]
  end

  def access=(value)
    self.details ||= {}
    self.details[:access] = value
  end
end

class PageHistory::GrantGroupAccess < PageHistory::UpdateParticipation
  include GrantAccess

  def self.tracks(changes, part)
    part.is_a?(GroupParticipation) && changes.keys.include?('access')
  end

  after_save :page_updated_at

  validates_presence_of :item_id
  validates_format_of :item_type, with: /Group/

  def participation=(part)
    self.item = part.try.group
    super
  end

  def description_key
    access.blank? ? super : super.sub('group_access', "group_#{access}_access")
  end
end

#
# DEPRECATED:
#
# please use PageHistory::GrantGroupAccess and hand in the participation
# to determine the level of access.
class PageHistory::GrantGroupFullAccess < PageHistory::GrantGroupAccess; end
class PageHistory::GrantGroupWriteAccess < PageHistory::GrantGroupAccess; end
class PageHistory::GrantGroupReadAccess < PageHistory::GrantGroupAccess; end

class PageHistory::RevokedGroupAccess < PageHistory::UpdateParticipation
  after_save :page_updated_at

  def self.tracks(changes, part)
    part.is_a?(GroupParticipation) &&
      !GroupParticipation.exists?(id: part.id)
  end

  def participation=(part)
    self.item = part.try.group
  end

  validates_format_of :item_type, with: /Group/
  validates_presence_of :item_id
end

class PageHistory::GrantUserAccess < PageHistory::UpdateParticipation
  include GrantAccess

  def self.tracks(changes, part)
    part.is_a?(UserParticipation) && changes.keys.include?('access')
  end

  after_save :page_updated_at

  validates_presence_of :item_id
  validates_format_of :item_type, with: /User/

  def participation=(part)
    self.item = part.try.user
    super
  end

  def description_key
    access.blank? ? super : super.sub('user_access', "user_#{access}_access")
  end
end

#
# DEPRECATED:
#
# please use PageHistory::GrantUserAccess and hand in the participation
# to determine the level of access.
class PageHistory::GrantUserFullAccess < PageHistory::GrantUserAccess; end
class PageHistory::GrantUserWriteAccess < PageHistory::GrantUserAccess; end
class PageHistory::GrantUserReadAccess < PageHistory::GrantUserAccess; end

class PageHistory::RevokedUserAccess < PageHistory::UpdateParticipation
  def self.tracks(changes, part)
    part.is_a?(UserParticipation) &&
      !UserParticipation.exists?(id: part.id)
  end

  def participation=(part)
    self.item = part.try.user
  end

  after_save :page_updated_at

  validates_format_of :item_type, with: /User/
  validates_presence_of :item_id
end

class PageHistory::ForComment < PageHistory
  after_save :page_updated_at

  validates_format_of :item_type, with: /Post/
  validates_presence_of :item_id

  # use past tense
  # super still uses the name of the actual class
  def description_key
    super.sub(/e?_comment/, 'ed_comment')
  end
end

class PageHistory::AddComment < PageHistory::ForComment ; end
class PageHistory::UpdateComment < PageHistory::ForComment ; end
class PageHistory::DestroyComment < PageHistory::ForComment ; end
