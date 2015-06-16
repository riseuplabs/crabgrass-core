class PageHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :page
  belongs_to :item, polymorphic: true

  validates_presence_of :user, :page

  serialize :details, Hash

  def self.send_single_pending_notifications
    pending_notifications.each do |page_history|
      if page_history.page.nil?
        page_history.destroy
        next
      end
      recipients_for_single_notification(page_history).each do |user|
        if Conf.paranoid_emails?
          Mailer.page_history_single_notification_paranoid(user, page_history).deliver
        else
          Mailer.page_history_single_notification(user, page_history).deliver
        end
      end
      page_history.update_attribute :notification_sent_at, Time.now
    end
  end

  def self.send_digest_pending_notifications
    pending_digest_notifications_by_page.each do |page_id, page_histories|
      page = Page.find(page_id)
      recipients_for_digest_notifications(page).each do |user|
        if Conf.paranoid_emails?
          Mailer.page_history_digest_notification_paranoid(user, page, page_histories).deliver
        else
          Mailer.page_history_digest_notification(user, page, page_histories).deliver
        end
      end
      PageHistory.update_all("notification_digest_sent_at = '#{Time.now}'", ["notification_digest_sent_at IS NULL and page_id = (?)", page_id])
    end
  end

  def self.pending_digest_notifications_by_page
    histories = {}
    PageHistory.order("created_at desc")
      .where(notification_digest_sent_at: nil).each do |page_history|
      histories[page_history.page.id] = [] if histories[page_history.page_id].nil?
      histories[page_history.page.id] << page_history
    end
    histories
  end

  def self.pending_notifications
    PageHistory.where(notification_sent_at: nil).all
  end

  def self.recipients_for_page(page)
    UserParticipation.where(page_id: page.id, watch: true).map(&:user_id)
  end

  def self.recipients_for_digest_notifications(page)
    User.where("receive_notifications = 'Digest'")
      .where(id: recipients_for_page(page)).all
  end

  def self.recipients_for_single_notification(page_history)
    users_watching_ids = recipients_for_page(page_history.page)
    users_watching_ids.delete(page_history.user.id)
    User.where("receive_notifications = 'Single' and `users`.id in (?)", users_watching_ids).all
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

class PageHistory::AddStar        < PageHistory; end
class PageHistory::RemoveStar     < PageHistory; end
class PageHistory::MakePublic     < PageHistory; end
class PageHistory::MakePrivate    < PageHistory; end
class PageHistory::StartWatching  < PageHistory; end
class PageHistory::StopWatching   < PageHistory; end

# Factory class for the different page updates
class PageHistory::Update < PageHistory
  def initialize(attrs = {}, options = {}, &block)
    page = attrs[:page]
    klass_for_update(page).new(attrs, options, &block)
  end

  def class_for_update(page)
    return PageHistory::MakePrivate if page.marked_as_private?
    return PageHistory::MakePublic if page.marked_as_public?
    # return PageHistory::ChangeOwner if page.owner_id_changed?
  end
end


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

class PageHistory::GrantGroupAccess < PageHistory
  before_save :add_details
  after_save :page_updated_at

  attr_accessor :participation

  validates_format_of :item_type, with: /Group/
  validates_presence_of :item_id

  # there always should be a participation given what this tracks granting
  # access. However in tests this is currently not the case.
  def add_details
    participation ||= page.participation_for(item)
    self.details = {
      access: participation.try.access_sym
    }
  end

  def description_key
    super.sub('grant', 'granted')
  end
end

class PageHistory::GrantGroupFullAccess < PageHistory::GrantGroupAccess; end
class PageHistory::GrantGroupWriteAccess < PageHistory::GrantGroupAccess; end
class PageHistory::GrantGroupReadAccess < PageHistory::GrantGroupAccess; end

class PageHistory::RevokedGroupAccess < PageHistory
  after_save :page_updated_at

  validates_format_of :item_type, with: /Group/
  validates_presence_of :item_id
end

class PageHistory::GrantUserAccess < PageHistory
  after_save :page_updated_at

  validates_format_of :item_type, with: /User/
  validates_presence_of :item_id

  def description_key
    super.sub('grant', 'granted')
  end
end

class PageHistory::GrantUserFullAccess < PageHistory::GrantUserAccess; end
class PageHistory::GrantUserWriteAccess < PageHistory::GrantUserAccess; end
class PageHistory::GrantUserReadAccess < PageHistory::GrantUserAccess; end

class PageHistory::RevokedUserAccess < PageHistory
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
