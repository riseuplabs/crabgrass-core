class Page::History < ActiveRecord::Base
  belongs_to :user
  belongs_to :page
  belongs_to :item, polymorphic: true

  validates_presence_of :user, :page

  serialize :details, Hash

  after_create :send_single_notification, if: :single_notification_wanted?

  def send_single_notification
    return if reload.notification_sent?
    Mailer::PageHistories.deliver_updates_for page,
                                              to: recipients_for_single_notification
  end

  # Let's wait 30 minutes so notifications for all changes to the same page
  # within that timeframe can be combined.
  handle_asynchronously :send_single_notification,
                        run_at: proc { 30.minutes.from_now }

  def single_notification_wanted?
    recipients_for_single_notification.present?
  end

  # all subclasses use the same partial
  def to_partial_path
    'page_histories/page_history'
  end

  def self.recipients_for_page(page)
    page.user_participations.where(watch: true).map(&:user_id)
  end

  def notification_sent?
    notification_sent_at.present?
  end

  def recipients_for_single_notification
    page.users.where(receive_notifications: 'Single')
        .where(user_participations: { watch: true })
        .where('users.id <> ?', user_id)
  end

  def description_key
    self.class.name.underscore.tr('/', '_')
  end

  # params to substitute in the translation of the description key
  def description_params
    { user_name: user_name, item_name: item_name }
  end

  def user_name
    user.try.display_name || 'Unknown/Deleted'
  end

  def item_name
    case item
    when Group then item.display_name
    when User then item.display_name
    else 'Unknown/Deleted'
    end
  end

  # no details by default
  def details_key; end

  protected

  def page_updated_at
    Page.where(id: page).update_all updated_at: created_at
  end
end

# Factory class for the different page updates
class Page::History::Update < Page::History
  def self.pick_class(attrs = {})
    class_for_update(attrs[:page])
  end

  protected

  def self.class_for_update(page)
    # FIXME: does not work, because page.public_changed? is always false
    return Page::History::MakePrivate if page.marked_as_private?
    return Page::History::MakePublic if page.marked_as_public?
    # return Page::History::ChangeOwner if page.owner_id_changed?
  end
end
class Page::History::MakePublic     < Page::History; end
class Page::History::MakePrivate    < Page::History; end

class Page::History::PageCreated < Page::History
  after_save :page_updated_at

  def description_key
    :page_history_user_created_page
  end
end

class Page::History::ChangeTitle < Page::History
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
      from: page.previous_changes['title'].first.try.truncate(100, separator: ' '),
      to: page.title.try.truncate(100, separator: ' ')
    }
  end
end

class Page::History::Deleted < Page::History
  after_save :page_updated_at

  def description_key
    :page_history_deleted_page
  end
end

class Page::History::UpdatedContent < Page::History
  after_save :page_updated_at
end

# Factory class for the different page updates
# To track updates to participations:
#  * inherit directly from this class
#  * define self.tracks on your class to return true for changes that should
#    be tracked.
# Changes will be a ActiveModel::Dirty changeset. You can use the activated
# and deactivated helper methods if you only need to look at the boolean value.
class Page::History::UpdateParticipation < Page::History
  def self.pick_class(attrs = {})
    class_for_update(attrs[:participation])
  end

  protected

  def self.class_for_update(participation)
    subclasses.detect do |klass|
      klass.tracks participation.previous_changes, participation
    end
  end

  def self.tracks(_changes, _part)
    false
  end

  def self.activated(old = nil, new = nil)
    new && !old
  end

  def self.deactivated(old = nil, new = nil)
    old && !new
  end
end

class Page::History::AddStar < Page::History::UpdateParticipation
  def self.tracks(changes, _part)
    activated(*changes[:star])
  end
end

class Page::History::RemoveStar < Page::History::UpdateParticipation
  def self.tracks(changes, _part)
    deactivated(*changes[:star])
  end
end

class Page::History::StartWatching < Page::History::UpdateParticipation
  def self.tracks(changes, _part)
    activated(*changes[:watch])
  end
end

class Page::History::StopWatching < Page::History::UpdateParticipation
  def self.tracks(changes, _part)
    deactivated(*changes[:watch])
  end
end

# Module for the methods shared between
# GrantGroupAccess and GrantUserAccess.
module Page::History::GrantAccess
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
  }.freeze
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

class Page::History::GrantGroupAccess < Page::History::UpdateParticipation
  include GrantAccess

  def self.tracks(changes, part)
    part.group? && changes.keys.include?('access')
  end

  after_save :page_updated_at

  validates_presence_of :item_id
  validates_format_of :item_type, with: /\AGroup\z/

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
# please use Page::History::GrantGroupAccess and hand in the participation
# to determine the level of access.
class Page::History::GrantGroupFullAccess < Page::History::GrantGroupAccess; end
class Page::History::GrantGroupWriteAccess < Page::History::GrantGroupAccess; end
class Page::History::GrantGroupReadAccess < Page::History::GrantGroupAccess; end

class Page::History::RevokedGroupAccess < Page::History::UpdateParticipation
  after_save :page_updated_at

  def self.tracks(_changes, part)
    # destroyed? does not work here because we destroy the participation via
    # page.groups
    part.group? && !part.class.exists?(id: part.id)
  end

  def participation=(part)
    self.item = part.try.group
  end

  validates_format_of :item_type, with: /\AGroup\z/
  validates_presence_of :item_id
end

class Page::History::GrantUserAccess < Page::History::UpdateParticipation
  include GrantAccess

  def self.tracks(changes, part)
    part.user? && changes.keys.include?('access')
  end

  after_save :page_updated_at

  validates_presence_of :item_id
  validates_format_of :item_type, with: /\AUser\z/

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
# please use Page::History::GrantUserAccess and hand in the participation
# to determine the level of access.
class Page::History::GrantUserFullAccess < Page::History::GrantUserAccess; end
class Page::History::GrantUserWriteAccess < Page::History::GrantUserAccess; end
class Page::History::GrantUserReadAccess < Page::History::GrantUserAccess; end

class Page::History::RevokedUserAccess < Page::History::UpdateParticipation
  def self.tracks(_changes, part)
    # destroyed? does not work here because we destroy the participation via
    # page.users
    part.user? && !part.class.exists?(id: part.id)
  end

  def participation=(part)
    self.item = part.try.user
  end

  after_save :page_updated_at

  validates_format_of :item_type, with: /\AUser\z/
  validates_presence_of :item_id
end

class Page::History::ForComment < Page::History
  after_save :page_updated_at

  validates_format_of :item_type, with: /\APost\z/
  validates_presence_of :item_id

  # use past tense
  # super still uses the name of the actual class
  def description_key
    super.sub(/e?_comment/, 'ed_comment')
  end
end

class Page::History::AddComment < Page::History::ForComment; end
class Page::History::UpdateComment < Page::History::ForComment; end
class Page::History::DestroyComment < Page::History::ForComment; end
